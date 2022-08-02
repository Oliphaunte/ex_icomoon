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

  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, [:name])
    |> validate_name()
  end

  defp validate_name(changeset) do
    changeset
    |> validate_required([:name])
    |> validate_length(:name, max: 300)
    |> unsafe_validate_unique(:name, Kurators.Repo)
    |> unique_constraint(:name)
  end

  @doc """
  Returns the list of accounts
  """
  def fetch_all do
    Repo.all(__MODULE__, prefix: "accounts")
  end

  @doc """
  Get organization by name
  """
  def get_by_name(name) do
    case Repo.get_by(__MODULE__, [name: name], prefix: "accounts") do
      %__MODULE__{} = organization -> {:ok, organization}
      nil -> {:error, :no_such_organization}
    end
  end

  @doc """
  Creates a user
  """
  def create(attrs \\ %{}) do
    %__MODULE__{}
    |> __MODULE__.changeset(attrs)
    |> Repo.insert(prefix: "accounts")
  end

  @doc """
  Updates a user
  """
  def update(user, attrs \\ %{}) do
    user
    |> __MODULE__.changeset(attrs)
    |> Repo.update(prefix: "accounts")
  end

  @doc """
  Deletes a user
  """
  def delete(%__MODULE__{} = user) do
    Repo.delete(user, prefix: "accounts")
  end
end
