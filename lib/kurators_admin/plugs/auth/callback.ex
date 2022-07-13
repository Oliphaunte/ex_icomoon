defmodule Kurators.Auth.Plugs.Callback do
  @moduledoc """
  This plug handles the callback for 3rd party authentication and runs on every request,
  but will not actually apply/do anything unless the user attempted authentication

  When a user authenticates through a 3rd party, there is a redirect from the authenticator
  and handle_callback/2 will pattern match to whatever authentication service response is passed through the sonn
  """
  @behaviour Plug

  import Plug.Conn
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]

  alias Kurators.Auth.{Token}

  # 60 seconds 60 minutes 24 hours 14 days
  @max_age 60 * 60 * 24 * 14
  @remember_me_cookie "_kurators_remember_me"
  @remember_me_options [
    sign: true,
    # max_age: @max_age, disabled temporarily until cookie based auth is confirmed working
    same_site: "Lax"
    # encrypt: "RHuSFYzNn0Lo5x6AlL2lyWTnSLQ30kPN79ny3loVEhzUAQ5a61Dc5sFTIUNJV77Y"
  ]

  @doc false
  def init(config), do: config

  @doc false
  def call(conn, _opts) do
    case get_session(conn, :session_uuid) do
      session_uuid -> handle_callback(conn)
    end
  end

  defp handle_callback(
         %Plug.Conn{params: %{"state" => state, "code" => code}, path_info: [_, context]} = conn
       ) do
    case Kurators.Auth.callback(context, %{"code" => code}, %{session_params: state}) do
      {:ok,
       %{user: user, token: %{"access_token" => access_token, "refresh_token" => refresh_token}}} ->
        # First check if the user exists by their email, if not, create the account and return the user
        {:ok, user} = Kurators.Auth.authenticate(user["email"], context)
        # Store the refresh token and the context/context
        {:ok, session_token} = Token.generate_token(user, refresh_token, context)

        conn
        |> put_session(:access_token, access_token)
        |> put_session(:session_token, session_token)
        |> put_session(:live_socket_id, "users_socket:#{session_token}")
        |> put_resp_cookie(@remember_me_cookie, session_token, @remember_me_options)
        |> redirect(to: "/")
        |> halt()

      # If a user manages to go through the auth flow and have a current, active auth session, pass forward to conn
      # {:ok, %{user: _user, token: %{"access_token" => _access_token}}} ->
      #   conn
      #   |> redirect(to: "/")

      {:error, _error} ->
        conn
        |> put_flash(:error, "Issue with single sign on authentication")
        |> redirect(to: "/auth")
        |> halt()
    end
  end

  @doc """
  handle_callback requests will always return an access_token and a user, and sometimes a refresh_token.

  In cases of re-authing a user, there is no refresh_token, we need to handle both situations.
  """
  defp handle_callback(conn), do: conn
end
