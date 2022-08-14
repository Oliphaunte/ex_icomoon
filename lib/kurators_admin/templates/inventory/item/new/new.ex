defmodule KuratorsAdmin.InventoryLive.New do
  use KuratorsAdmin, :live_view

  alias Kurators.Inventory.Item

  @impl true
  def mount(_params, _session, socket) do
    {
      :ok,
      socket
      #  |> assign(:item_changeset, Item.changeset(%Item{}))}
    }
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end
end
