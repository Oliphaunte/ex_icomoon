defmodule Kurators.Accounts.User do
  use Ecto.Schema

  import Ecto.Changeset

  alias Kurators.Repo
  alias Kurators.Accounts.{Role, Status, Organization}
  alias Kurators.Auth.{Token, SignInCode}

  @primary_key {:id, :binary_id, autogenerate: true}
  @schema_prefix "accounts"
  @foreign_key_type :binary_id

  schema "users" do
    field(:email, :string)
    field(:secondary_email, :string)
    field(:username, :string)
    field(:first_name, :string)
    field(:middle_name, :string)
    field(:last_name, :string)
    field(:profile_picture, :string, default: "user")
    field(:confirmed_at, :utc_datetime)
    has_one(:tokens, Token)
    has_one(:sign_in_codes, SignInCode)
    belongs_to(:statuses, Status, foreign_key: :statuses_id, type: :binary_id)
    belongs_to(:roles, Role, foreign_key: :roles_id, type: :binary_id)
    belongs_to(:organizations, Organization, foreign_key: :organizations_id, type: :binary_id)

    timestamps()
  end

  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, [
      :email,
      :secondary_email,
      :username,
      :first_name,
      :middle_name,
      :last_name,
      :profile_picture,
      :confirmed_at,
      :statuses_id,
      :roles_id,
      :organizations_id
    ])
    |> unique_constraint(:accounts_id)
    |> validate_email()
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must be a valid email address")
    |> validate_length(:email, max: 160)
    |> unsafe_validate_unique(:email, Kurators.Repo)
    |> unique_constraint(:email)
  end

  def valid_user_actions do
    [
      "can_add_users",
      "can_delete_users",
      "can_add_new_fields",
      "can_modify_fields",
      "can_comment"
    ]
  end

  @doc """
  A user changeset for changing the email.

  It requires the email to change otherwise an error is added.
  """
  def email_changeset(user, attrs) do
    user
    |> cast(attrs, [:email])
    |> validate_email()
    |> case do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not change")
    end
  end

  @doc """
  Confirms the account by settings `confirmed_at`
  """
  def confirm_changeset(user) do
    now = DateTime.truncate(DateTime.utc_now(), :second)

    change(user, confirmed_at: now)
  end

  @doc """
  Returns the list of users
  """
  def fetch_all do
    users =
      __MODULE__
      |> Repo.all(prefix: "accounts")
      |> Repo.preload(:roles, prefix: "accounts")
      |> Repo.preload(:statuses, prefix: "accounts")

    {:ok, users}
  end

  @doc """
  Gets a single user by id
  """
  def get_user_by_id(id) do
    case Ecto.UUID.cast(id) do
      {:ok, id} -> Repo.get_by(__MODULE__, [id: id], prefix: "accounts")
      _ -> {:error, nil}
    end
  end

  @doc """
  Gets a user by email
  """
  def get_user_by_email(email) do
    case Repo.get_by(__MODULE__, [email: email], prefix: "accounts") do
      %__MODULE__{} = user -> {:ok, user}
      nil -> {:error, :no_such_user}
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