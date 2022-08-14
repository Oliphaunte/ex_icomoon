defmodule <%= unless main_module = "Kurators", do: "#{main_module}." %>Kurators.Auth.Token do
  use Ecto.Schema

  require Logger

  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias <%= main_module %>.Kurators.{Crypto, Repo}
  alias <%= unless main_module = "Kurators", do: "#{main_module}." %>Kurators.Accounts.User

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

  @doc """
  Creates a session token of random bytes AND encrypts any refresh tokens passed (otherwise, refresh_token remains nil)

  The token is then added OR updated (keeping the session fresh)

  Context refers to the device/method used to authenticate the user
  """
  def create(user, refresh_token \\ nil, context \\ "session") do
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
        Logger.info("Failed to generate token of context type: #{context}")
    end
  end

  defp encrypt_refresh_token(refresh_token) when is_nil(refresh_token), do: nil
  defp encrypt_refresh_token(refresh_token), do: Crypto.encrypt(:refresh_token, refresh_token)

  defp token_and_context_query(token), do: from(__MODULE__, where: [token: ^token])

  @doc """
  Checks if a session_token has an existing entry in the tokens table

  1. The user has an existing token with our authentication service
  2. The user has an existing token with a third party authentication service
  3. The user does not have an existing/valid token
  """
  def check_token(session_token, access_token \\ nil) do
    case get_user_by_session_token(session_token) do
      {:ok, %{context: context, refresh_token: refresh_token}} ->
        check_access_token(session_token, context, access_token, refresh_token)

      {:ok, %{user: user}} ->
        {:ok, user}

      {:error, error} ->
        {:error, error}

      _ ->
        {:error, :not_found}
    end
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

      {context, refresh_token, _user} ->
        decrypt_refresh_token(context, refresh_token)

      {:error, error} ->
        {:error, error}

      nil ->
        nil
    end
  end

  defp decrypt_refresh_token(context, refresh_token) do
    case Crypto.decrypt(:refresh_token, refresh_token, @max_age) do
      {:ok, refresh_token} ->
        {:ok, %{context: context, refresh_token: refresh_token}}

      {:error, error} ->
        {:error, error}
    end
  end

  # return the user from the db (not the one from the auth provider) if the access token is valid, otherwise try the refresh token
  defp check_access_token(session_token, context, access_token, refresh_token)
       when is_nil(access_token) do
    try_refresh_token(context, session_token, refresh_token)
  end

  defp check_access_token(session_token, context, access_token, refresh_token) do
    case Kurators.Auth.fetch_user(context, %{"access_token" => access_token}) do
      {:ok, user} ->
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
