defmodule KuratorsAdmin.UsersLive do
  use KuratorsAdmin, :live_view

  alias Kurators.Accounts.Users

  @impl true
  def mount(_params, _session, socket) do
    users = if connected?(socket), do: Users.list_users(), else: []

    {:ok,
     assign(socket,
       results: [],
       query: "",
       users: users
     )}
  end

  @impl true
  def handle_event("suggest", %{"no_changeset" => %{"user_search" => query}}, socket) do
    {:noreply, assign(socket, results: search(query, socket.assigns.users), query: query)}
  end

  defp search(query, users) do
    if not KuratorsWeb.Endpoint.config(:code_reloader) do
      raise "action disabled when not in development"
    end

    users =
      Enum.filter(users, fn event ->
        String.match?(event.email, ~r/^#{query}/)
      end)
  end
end
