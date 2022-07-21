defmodule Kurators.Auth.Token do
  use Ecto.Schema

  require Logger

  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias Kurators.{Crypto, Repo}
  alias Kurators.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @schema_prefix "auth"
  @foreign_key_type :binary_id

  @rand_size 32

  # 60 seconds 60 minutes 24 hours 14 days
  @max_age 60 * 60 * 24 * 14
  @session_validity_in_days 14

  schema "tokens" do
    field(:token, :string)
    field(:refresh_token, :string)
    field(:last_called_at, :utc_datetime)
    field(:context, :string)
    belongs_to(:user, User, foreign_key: :user_id, type: :binary_id)

    timestamps(updated_at: false)
  end

  def changeset(token, attrs \\ %{}) do
    token
    |> cast(attrs, [:token, :refresh_token, :context, :last_called_at, :user_id])
    |> unique_constraint(:user_id)
  end

  defp encrypt_refresh_token(refresh_token) when is_nil(refresh_token), do: nil

  defp encrypt_refresh_token(refresh_token) do
    Crypto.encrypt(:refresh_token, refresh_token)
  end

  @doc """
  Generates a session token of random bytes

  Stores refresh token and context of the third party auth used
  """
  def generate_token(user, refresh_token \\ nil, context \\ "session") do
    refresh_token = encrypt_refresh_token(refresh_token)
    session_token = :crypto.strong_rand_bytes(@rand_size) |> :base64.encode()

    attrs = %{
      token: session_token,
      refresh_token: refresh_token,
      context: context,
      user_id: user.id,
      last_called_at: DateTime.truncate(DateTime.utc_now(), :second)
    }

    result =
      %__MODULE__{}
      |> __MODULE__.changeset(attrs)
      |> Repo.insert_or_update(prefix: "auth")

    case result do
      {:ok, token} ->
        {:ok, token}

      {:error, _changeset} ->
        Logger.info("Failed to generate token of context type:application_starter #{context}")
    end
  end

  defp token_and_context_query(token) do
    from(__MODULE__, where: [token: ^token])
  end

  defp get_user_by_session_token(token) do
    query =
      from(token in token_and_context_query(token),
        join: user in assoc(token, :user),
        where: token.inserted_at > ago(@session_validity_in_days, "day"),
        select: {token.context, token.refresh_token, user}
      )

    case Repo.one(query, prefix: "auth") do
      {_context, refresh_token, %User{} = user} when is_nil(refresh_token) ->
        {:ok, %{user: user}}

      {context, refresh_token, %User{} = user} ->
        decrypt_refresh_token(context, refresh_token, user)

      {:error, error} ->
        {:error, error}

      nil ->
        nil
    end
  end

  @doc """

  """
  def check_token(session_token) do
    case get_user_by_session_token(session_token) do
      {:ok, %{context: context, refresh_token: refresh_token}} ->
        try_refresh_token(context, session_token, refresh_token)

      {:ok, %{user: user}} ->
        {:ok, user}

      {:error, error} ->
        {:error, error}

      _ ->
        {:error, :not_found}
    end
  end

  def check_token(session_token, access_token) do
    case get_user_by_session_token(session_token) do
      {:ok, %{context: context, refresh_token: refresh_token, user: user}} ->
        login_by_access_token(user, session_token, context, access_token, refresh_token)

      {:error, error} ->
        {:error, error}

      _ ->
        {:error, :not_found}
    end
  end

  @doc """
  return the user from the db (not the one from the auth provider) if the access token is valid, otherwise try the refresh token
  """
  def login_by_access_token(user, session_token, context, access_token, refresh_token) do
    case Kurators.Auth.fetch_user(context, %{"access_token" => access_token}) do
      {:ok, _user} ->
        {:ok, %{session_token: session_token, access_token: access_token, user: user}}

      {:error, _error} ->
        try_refresh_token(context, session_token, refresh_token)
    end
  end

  # If the refresh token is valid, use the returned access token to authenticate the user, otherwise, return an error
  defp try_refresh_token(context, session_token, refresh_token) do
    case Kurators.Auth.refresh_access_token(context, %{"refresh_token" => refresh_token}) do
      {:ok, %{"access_token" => access_token}} ->
        check_token(session_token, access_token)

      {:error, error} ->
        {:error, error}

      _ ->
        {:error, :not_found}
    end
  end

  defp decrypt_refresh_token(context, refresh_token, user) do
    case Crypto.decrypt(:refresh_token, refresh_token, @max_age) do
      {:ok, refresh_token} ->
        {:ok, %{context: context, refresh_token: refresh_token, user: user}}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Deletes the signed token with the given context
  """
  def delete_session_token(token) do
    Repo.delete_all(token_and_context_query(token), prefix: "auth")
    :ok
  end

  @doc """
  Gets all tokens for the given user for the given contexts.
  """
  def user_and_contexts_query(user, :all),
    do: from(t in __MODULE__, where: t.user_id == ^user.id)

  def user_and_contexts_query(user, [_ | _] = contexts),
    do: from(t in __MODULE__, where: t.user_id == ^user.id and t.context in ^contexts)
end
