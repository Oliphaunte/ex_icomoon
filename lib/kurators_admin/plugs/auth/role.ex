defmodule Kurators.Auth.Plugs.Role do
  @moduledoc """
  This plug ensures that a user has a particular role before accessing a given route.

  ## Example
  Let's suppose we have three roles: :admin, :manager and :user
  If you want a user to have at least manager role, so admins and managers are authorised

  plug Kurators.Auth.Plugs.Role, [:admin, :manager]

  If you only want to give access to an admin:any()

  plug Kurators.Auth.Plugs.Role, :admin
  """
  @behaviour Plug

  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2]

  alias Kurators.Auth.{TokenHandler}
  alias Kurators.Accounts.Users

  @doc false
  @spec init(any()) :: any()
  def init(config), do: config

  @doc false
  @spec call(Conn.t(), atom() | [atom()]) :: Conn.t()
  def call(conn, roles) do
    case get_session(conn, :session_token) do
      nil ->
        maybe_halt(false, conn)

      session_token ->
        get_user(conn, roles, session_token)
    end
  end

  defp get_user(conn, roles, session_token) do
    case TokenHandler.check_token(session_token) do
      {:ok, %{user: user}} ->
        user
        |> has_role?(roles)
        |> maybe_halt(conn)

      _ ->
        maybe_halt(nil, conn)
    end
  end

  defp has_role?(%Users{role: role}, role), do: true
  defp has_role?(_user, _role), do: false

  defp maybe_halt(true, conn), do: conn

  defp maybe_halt(_any, conn) do
    conn
    |> redirect(to: "/auth")
    |> halt()
  end
end
