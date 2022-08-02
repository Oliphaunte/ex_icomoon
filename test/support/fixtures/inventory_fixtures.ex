defmodule Kurators.InventoryFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Kurators.Inventory` context.
  """

  @doc """
  Generate a item.
  """
  def item_fixture(attrs \\ %{}) do
    {:ok, item} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Kurators.Inventory.create_item()

    item
  end
end
