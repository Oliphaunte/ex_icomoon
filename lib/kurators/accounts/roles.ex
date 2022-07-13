defmodule Kurators.Accounts.Roles do
  use Ecto.Schema

  import Ecto.Changeset

  alias Kurators.Auth.Status

  @schema_prefix "accounts"

  embedded_schema do
    field(:name, :string)
    embeds_one(:status, Status)
  end

  def changeset(attrs \\ %{}) do
    %__MODULE__{}
    |> cast(attrs, [:status])
  end
end
