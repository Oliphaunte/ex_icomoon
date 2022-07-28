defmodule Kurators.Accounts.Organization do
  use Ecto.Schema

  import Ecto.Changeset

  alias Kurators.Repo
  alias Kurators.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @schema_prefix "accounts"
  @foreign_key_type :binary_id

  schema "organizations" do
    field(:name, :string)
    has_many(:users, User)

    timestamps()
  end

  def changeset(account, attrs \\ %{}) do
    account
    |> cast(attrs, [:name])
    |> validate_name()
  end

  defp validate_name(changeset) do
    changeset
    |> validate_required([:name])
    |> validate_length(:name, max: 80)
    |> unsafe_validate_unique(:name, Repo)
    |> unique_constraint(:name)
  end
end
