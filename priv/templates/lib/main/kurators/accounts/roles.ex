defmodule <%= main_module %>.Accounts.Role do
  use Ecto.Schema

  import Ecto.Changeset

  alias <%= main_module %>.Repo
  alias <%= main_module %>.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @schema_prefix "accounts"
  @foreign_key_type :binary_id

  schema "roles" do
    field(:name, :string)
    field(:default, :boolean)
    has_many(:user, User)

    timestamps()
  end

  def changeset(role, attrs \\ %{}) do
    role
    |> cast(attrs, [:name, :default])
    |> validate_required([:name])
    |> validate_length(:name, max: 160)
    |> unsafe_validate_unique(:name, Kurators.Repo)
    |> unique_constraint(:name)
  end

  def create(attrs \\ %{}) do
    %__MODULE__{}
    |> __MODULE__.changeset(attrs)
    |> Repo.insert(prefix: "accounts")
  end

  def get_by_name(name) do
    case Repo.get_by(__MODULE__, [name: name], prefix: "accounts") do
      %__MODULE__{} = role -> {:ok, role}
      nil -> {:error, :no_such_role}
    end
  end
end
