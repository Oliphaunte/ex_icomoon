defmodule KuratorsAdmin.UsersLive do
  use KuratorsAdmin, :live_view

  require Logger

  alias Kurators.Accounts.User

  @impl true
  def mount(_params, _session, socket) do
    {:ok, users} = if connected?(socket), do: User.fetch_all(), else: {:ok, []}

    Logger.info("Loaded users")

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
    # if not KuratorsWeb.Endpoint.config(:code_reloader) do
    #   raise "action disabled when not in development"
    # end

    # users =
    #   Enum.filter(users, fn event ->
    #     String.match?(event.email, ~r/^#{query}/)
    #   end)
  end
end
