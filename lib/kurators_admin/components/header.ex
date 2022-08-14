defmodule Header do
  use KuratorsAdmin, :live_component

  alias Kurators.Auth.{TokenHandler}

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("logout", _session, socket) do
    TokenHandler.delete_token(socket.assigns.session_token)

    KuratorsAdmin.Endpoint.broadcast(
      "session_token:#{socket.assigns.session_token}",
      "disconnect",
      %{}
    )

    socket = socket |> assign(:current_user, nil)

    {:noreply, push_redirect(socket, to: "/", replace: true)}
  end
end
