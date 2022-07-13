defmodule Kurators.Accounts.Users do
  use Ecto.Schema

  import Ecto.Changeset

  alias Kurators.Repo
  alias Kurators.Auth.{Roles, Status, Token, SignInCode}

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
    embeds_one(:status, Status)
    embeds_one(:role, Roles)
    belongs_to(:accounts, Accounts, foreign_key: :accounts_id, type: :binary_id)

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
      :accounts_id
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
      "can_make_thumbnails",
      "can_add_users",
      "can_delete_users",
      "can_add_new_fields",
      "can_modify_fields",
      "can_view_high_res_image",
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
  def list_users do
    Repo.all(__MODULE__, prefix: "accounts")
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
  def create_user(attrs \\ %{}) do
    %__MODULE__{}
    |> __MODULE__.changeset(attrs)
    |> Repo.insert(prefix: "accounts")
  end

  @doc """
  Updates a user
  """
  def update_user(user, attrs \\ %{}) do
    user
    |> __MODULE__.changeset(attrs)
    |> Repo.update(prefix: "accounts")
  end

  @doc """
  Deletes a user
  """
  def delete_user(%__MODULE__{} = user) do
    Repo.delete(user, prefix: "accounts")
  end
end
