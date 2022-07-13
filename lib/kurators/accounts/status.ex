defmodule Kurators.Accounts.Status do
  use Ecto.Schema

  import Ecto.Changeset

  @schema_prefix "accounts"

  embedded_schema do
    field(:name, :string)
  end

  def changeset(attrs \\ %{}) do
    %__MODULE__{}
    |> cast(attrs, [:status])
  end
end
