defmodule KuratorsAdmin.OnMount do
  import Phoenix.LiveView

  alias Kurators.Auth.TokenHandler

  @doc """
  on_mount for admins
  """
  def on_mount(
        :check_authenticated,
        _params,
        %{
          "session_uuid" => session_uuid,
          "session_token" => session_token,
          "access_token" => access_token
        },
        socket
      ) do
    case TokenHandler.check_token(session_token, access_token) do
      {:ok, %{access_token: access_token, session_token: session_token, user: user}} ->
        socket =
          socket
          |> assign(:session_uuid, session_uuid)
          |> assign(:session_token, session_token)
          |> assign(:access_token, access_token)
          |> assign(:current_user, user)

        {:cont, socket}

      {:error, _error} ->
        {:halt, redirect(socket, to: "/auth")}

      _ ->
        {:halt, redirect(socket, to: "/auth")}
    end
  end

  def on_mount(
        _action,
        _params,
        %{"session_uuid" => session_uuid, "session_token" => session_token},
        socket
      ) do
    socket =
      socket
      |> assign(:session_uuid, session_uuid)
      |> assign_new(:current_user, fn -> TokenHandler.check_token(session_token) end)

    {:cont, socket}

    # if socket.assigns["current_user"] do
    #   {:cont, socket}
    # else
    #   # {:halt, redirect(socket, to: "/auth")}
    # end
  end

  def on_mount(_action, _params, %{"session_uuid" => session_uuid}, socket) do
    socket =
      socket
      |> assign(:session_uuid, session_uuid)

    {:halt, redirect(socket, to: "/auth")}
  end
end
