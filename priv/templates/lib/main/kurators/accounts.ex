defmodule <%= main_module %>.Accounts do
  @moduledoc """
  Authentication piece that allows users to login via either their email/code or 3rd party

  TODO: 2-factor auth (yubikey?)
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias <%= main_module %>.Repo
  alias <%= main_module %>.Accounts.User

  @pubsub <%= main_module %>.PubSub
  @primary_key {:id, :binary_id, autogenerate: true}
  @schema_prefix "accounts"
  @foreign_key_type :binary_id

  schema "accounts" do
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

  @doc """
  Returns the list of accounts
  """
  def list_accounts do
    Repo.all(__MODULE__, prefix: "accounts")
  end

  @doc """
  Creates an account
  """
  def get_by_name(name) do
    case Repo.get_by(__MODULE__, [name: name], prefix: "accounts") do
      %__MODULE__{} = account -> {:ok, account}
      nil -> {:error, :no_such_account}
    end
  end

  @doc """
  Creates an account
  """
  def create_account(attrs \\ %{}) do
    %__MODULE__{}
    |> __MODULE__.changeset(attrs)
    |> Repo.insert(prefix: "accounts")
  end

  @doc """
  Updates an account
  """
  def update_account(user, attrs \\ %{}) do
    user
    |> __MODULE__.changeset(attrs)
    |> Repo.update(prefix: "accounts")
  end

  @doc """
  Deletes an account
  """
  def delete_account(%__MODULE__{} = user) do
    Repo.delete(user, prefix: "accounts")
  end

  defp topic(user_id), do: "users:#{user_id}"

  def subscribe(user_id) do
    Phoenix.PubSub.subscribe(@pubsub, topic(user_id))
  end

  def unsubscribe(user_id) do
    Phoenix.PubSub.unsubscribe(@pubsub, topic(user_id))
  end

  defp broadcast!(%User{} = user, msg) do
    Phoenix.PubSub.broadcast!(@pubsub, topic(user.id), {__MODULE__, msg})
  end
end
