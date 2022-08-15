defmodule Kurators.Auth do
  @moduledoc """
  Authentication piece that allows users to login via either their email/code or 3rd party

  TODO: 2-factor auth (yubikey?)
  """
  import Ecto.Query, warn: false

  require Logger

  alias Kurators.Repo
  alias Assent.Strategy.OAuth2
  alias Kurators.Auth.{SignInCode}
  alias Kurators.Accounts
  alias Kurators.Accounts.User

  defp get_primary_account() do
    Accounts |> first(:inserted_at) |> Repo.one()
  end

  defp notify_user(user) do
    with {:ok, sign_in_code} <- SignInCode.create(user),
         :ok <- SignInCode.notify_user_of_sign_in_code(user, sign_in_code) do
      {:ok, sign_in_code}
    else
      _ ->
        Logger.error("Could not notify user of sign in code")
        {:error, :not_valid}
    end
  end

  @doc """
  Creates a sign_in_code and notifies the user

  When a user does not exist, it creates the user and then passes the sign_in_code
  """
  def authenticate(email) do
    case User.get_user_by_email(email) do
      {:ok, %User{} = user} ->
        notify_user(user)

      {:error, :no_such_user} ->
        {:ok, %User{} = user} =
          User.create(%{email: email, accounts_id: get_primary_account().id})

        notify_user(user)
    end
  end

  @doc """
  Authorizes user via 3rd party

  Creates the user if authorized through 3rd party and account does not exist already
  """
  def authenticate(email, _context) do
    case User.get_user_by_email(email) do
      {:ok, %User{} = user} ->
        {:ok, user}

      {:error, :no_such_user} ->
        User.create(%{email: email, accounts_id: get_primary_account().id})
    end
  end

  # Assent
  @spec authorize_url(String.t()) :: {:ok, map()} | {:error, term()}
  def authorize_url(provider) when is_binary(provider) do
    provider = String.to_existing_atom(provider)

    authorize_url(provider)
  end

  @spec authorize_url(atom()) :: {:ok, map()} | {:error, term()}
  def authorize_url(provider) when is_atom(provider) do
    config = config!(provider)

    config[:strategy].authorize_url(config)
  end

  @spec callback(String.t(), map(), map()) :: {:ok, map()} | {:error, term()}
  def callback(provider, params, session_params) when is_binary(provider) do
    provider = String.to_existing_atom(provider)

    callback(provider, params, session_params)
  end

  @spec callback(atom(), map(), map()) :: {:ok, map()} | {:error, term()}
  def callback(provider, params, session_params) when is_atom(provider) do
    config =
      provider
      |> config!()
      |> Assent.Config.put(:session_params, session_params)

    config[:strategy].callback(config, params)
  end

  @doc """
  Refreshes the access token when a user enters the page and has an active access_token
  """
  def refresh_access_token(provider, refresh_token, params \\ [])

  @spec refresh_access_token(String.t(), map(), Keyword.t()) :: {:ok, map()} | {:error, term()}
  def refresh_access_token(provider, refresh_token, params) when is_binary(provider) do
    provider = String.to_existing_atom(provider)

    refresh_access_token(provider, refresh_token, params)
  end

  @spec refresh_access_token(atom(), map(), Keyword.t()) :: {:ok, map()} | {:error, term()}
  def refresh_access_token(provider, refresh_token, params) when is_atom(provider) do
    config = config!(provider)
    config = Keyword.merge(config[:strategy].default_config(nil), config)

    OAuth2.refresh_access_token(config, refresh_token, params)
  end

  @doc """
  Fetch the user from the third-party auth
  """
  def fetch_user(provider, token, params \\ [], headers \\ [])

  @spec fetch_user(String.t(), map(), map() | Keyword.t(), [{binary(), binary()}]) ::
          {:ok, map()} | {:error, term()}
  def fetch_user(provider, token, params, headers) when is_binary(provider) do
    provider = String.to_existing_atom(provider)

    fetch_user(provider, token, params, headers)
  end

  @spec fetch_user(atom(), map(), map() | Keyword.t(), [{binary(), binary()}]) ::
          {:ok, map()} | {:error, term()}
  def fetch_user(provider, token, params, headers) when is_atom(provider) do
    config = config!(provider)
    config = Keyword.merge(config[:strategy].default_config(nil), config)

    OAuth2.fetch_user(config, token, params, headers)
  end

  defp config!(provider) do
    Application.get_env(:kurators, :strategies)[provider] ||
      raise "No provider configurations for #{provider}"
  end
end
