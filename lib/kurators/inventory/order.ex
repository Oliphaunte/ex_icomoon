defmodule Kurators.Inventory.Order do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @schema_prefix "inventory"
  @foreign_key_type :binary_id

  schema "orders" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
