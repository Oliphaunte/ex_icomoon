defmodule Kurators.Auth.Plugs.Session do
  @moduledoc """
  There are 4 potential states of authentication/authorization
    1. There is an access_token, which is third-party authentication
    2. There is an authentication_token inside the _kurators_remember_me cookie, which is a persistent session authentication
    3. There is a user associated with the session_token, which is browser session authentication
    4. No authentication

    An important point to remember, access_tokens are stored purely in the browser session. So if a user quits their browser and returns, they are still authenticated through
    a 3rd party auth, but no longer have an access_token. This means that the session token SHOULD return a refresh_token, that will then be used to fetch a new access token which
    is then stored in the browser session. Security, and whatnot.

    This is an important note because that means in situations where we only have a session_token, we must remember that authentication could still be 3rd and not just email.
  """

  @behaviour Plug

  import Plug.Conn
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]

  alias Kurators.Auth.{TokenHandler}

  # 60 seconds 60 minutes 24 hours 14 days
  @max_age 60 * 60 * 24 * 14
  @remember_me_cookie "_kurators_remember_me"
  @remember_me_options [
    max_age: @max_age,
    same_site: "Lax",
    encrypt: true
  ]

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_session(conn, :session_uuid) do
      nil -> put_session(conn, :session_uuid, Ecto.UUID.generate())
      session_uuid -> handle_session(conn, session_uuid)
    end
  end

  defp handle_session(conn, session_uuid) do
    case validate_session(conn, session_uuid) do
      # 3rd party
      {:ok, %{session_token: session_token, access_token: access_token, user: _user}} ->
        conn
        |> put_session(:access_token, access_token)
        |> put_session(:session_token, session_token)
        |> put_session(:live_socket_id, "users_socket:#{session_token}")
        |> put_resp_cookie(@remember_me_cookie, session_token, @remember_me_options)

      # 3rd party or persistent session auth
      {:ok, %{session_token: session_token, remember_me: true}} ->
        conn
        |> put_session(:session_token, session_token)
        |> put_session(:live_socket_id, "users_socket:#{session_token}")
        |> put_resp_cookie(@remember_me_cookie, session_token, @remember_me_options)

      # temporal browser auth
      {:ok, %{session_token: session_token, remember_me: false}} ->
        conn
        |> put_session(:session_token, session_token)
        |> put_session(:live_socket_id, "users_socket:#{session_token}")

      _ ->
        unless(String.match?(conn.request_path, ~r/\/auth/)) do
          conn
          |> put_flash(:error, "Please sign in")
          |> redirect(to: "/auth")
          |> halt()
        else
          conn
        end
    end
  end

  @doc """
  third-party authentication
  """
  def validate_session(
        %Plug.Conn{
          private: %{
            plug_session: %{"session_token" => session_token, "access_token" => access_token}
          }
        },
        _session_uuid
      ) do
    TokenHandler.check_token(session_token, access_token)
  end

  @doc """
  Check if the cookie is valid, because if it is, we need to reset its lifespan.
  If it is invalid, invalidate the cookie and check for an in-session session_token
  """
  def validate_session(
        %Plug.Conn{cookies: %{"_kurators_remember_me" => remember_me_cookie}} = conn,
        _session_uuid
      ) do
    # session_token =
    #   fetch_cookies(conn, signed: ~w(kurators_remember_me))
    #   |> Map.from_struct()
    #   |> get_in([:cookies, "_kurators_remember_me"])
  end

  @doc """
  Two possibilities
  1. third-party authentication -> fetch the refresh token and provider and use that to get an updated access token
  2. persistent session authentication ->
  """
  def validate_session(
        %Plug.Conn{private: %{plug_session: %{"session_token" => session_token}}},
        _session_uuid
      ) do
    TokenHandler.check_token(session_token)
  end

  @doc """
  browser session authentication
  """
  def validate_session(_conn, session_uuid) do
    case :ets.lookup(:token_table, :"#{session_uuid}") do
      [{_, table_token}] ->
        :ets.delete(:token_table, :"#{session_uuid}")

        {:ok, table_token}

      _ ->
        {:error, nil}
    end
  end

  # Call this when we logout or force logout
  defp renew_session(conn) do
    session_uuid = get_session(conn, :session_uuid)

    conn
    |> configure_session(renew: true)
    |> clear_session()
    |> put_session(:session_uuid, session_uuid)
  end
end
