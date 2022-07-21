defmodule KuratorsAdmin.UserLive do
  use KuratorsAdmin, :live_view

  alias Kurators.Accounts.User

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    user = User.get_user_by_id(id)

    {:ok, assign(socket, user: user)}
  end
end
