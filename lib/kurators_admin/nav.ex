defmodule KuratorsAdmin.Nav do
  import Phoenix.LiveView

  def on_mount(:default, _params, _session, socket) do
    {:cont,
     socket
     |> attach_hook(:active_path, :handle_params, &set_active_path/3)}
  end

  defp set_active_path(_params, url, socket) do
    {:cont, assign(socket, active_path: URI.parse(url).path)}
  end

  # defp current_user(socket) do
  #   socket.assigns.current_user[:username]
  # end
end
