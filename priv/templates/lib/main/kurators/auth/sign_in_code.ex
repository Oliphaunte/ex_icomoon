defmodule <%= unless main_module = "Kurators", do: "#{main_module}." %>Kurators.Auth.SignInCode do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias <%= main_module %>.{Repo, Mailer}
  alias <%= unless main_module = "Kurators", do: "#{main_module}." %>Kurators.Accounts.User

  @sign_in_code_length 6
  @sign_in_code_regex Regex.compile!("^\\d{" <> Integer.to_string(@sign_in_code_length) <> "}$")
  @max_sign_in_attempts 3
  @lifespan_of_user_sign_in_code_in_minutes 15

  @primary_key {:id, :binary_id, autogenerate: true}
  @schema_prefix "auth"
  @foreign_key_type :binary_id

  schema "sign_in_codes" do
    field(:code, :string, virtual: true)
    field(:hashed_code, :string)
    field(:sign_in_attempts, :integer, default: 0)
    belongs_to(:user, User)

    timestamps(updated_at: false)
  end

  defp generate_code(changeset) do
    code = Enum.map(1..@sign_in_code_length, fn _ -> Enum.random(0..9) end) |> Enum.join("")

    changeset
    |> put_change(:code, code)
    |> put_change(:hashed_code, Bcrypt.hash_pwd_salt(code))
  end

  @doc false
  def create_changeset(sign_in_code, attrs) do
    sign_in_code
    |> cast(attrs, [:user_id])
    |> validate_required([:user_id])
    |> generate_code()
    |> foreign_key_constraint(:user_id)
  end

  def valid_code?(%__MODULE__{hashed_code: hashed_code}, code)
      when is_binary(hashed_code) and byte_size(code) == @sign_in_code_length do
    Bcrypt.verify_pass(code, hashed_code)
  end

  def valid_code?(_, _), do: Bcrypt.no_user_verify()

  @doc """

  """
  def create(%User{id: user_id}) do
    %__MODULE__{}
    |> __MODULE__.create_changeset(%{user_id: user_id})
    |> Repo.insert(prefix: "auth")
  end

  def notify_user_of_sign_in_code(user, sign_in_code) do
    user
    |> KuratorsAdmin.VerificationEmail.verification_code(sign_in_code.code)
    |> Mailer.deliver()

    :ok
  end

  @doc """
  Check sign in code

  ## Examples

      iex> check_sign_in_code("123", "000000")
      {:ok, %__MODULE__{}}

      iex> check_sign_in_code("123", "notvalid")
      {:error, :not_valid}

      iex> check_sign_in_code("456", "000000")
      {:error, not_found_or_expired}
  """
  def check_sign_in_code(code_id, code_from_user) when is_binary(code_from_user) do
    case get_user_sign_in_code(code_id) do
      %__MODULE__{} = user_sign_in_code ->
        increment_sign_in_attempts(user_sign_in_code)

        if __MODULE__.valid_code?(user_sign_in_code, code_from_user) do
          delete_sign_in_code(user_sign_in_code)

          {:ok, user_sign_in_code}
        else
          {:error, :not_valid}
        end

      nil ->
        mitigate_against_timing_attacks()
        {:error, :not_found_or_expired}
    end
  end

  defp get_user_sign_in_code(id) do
    from(s in __MODULE__,
      where: s.id == ^id,
      where: s.inserted_at >= ago(@lifespan_of_user_sign_in_code_in_minutes, "minute"),
      where: s.sign_in_attempts < @max_sign_in_attempts
    )
    |> Repo.one(prefix: "auth")
  end

  defp increment_sign_in_attempts(%__MODULE__{} = sign_in_code) do
    from(s in __MODULE__,
      where: s.id == ^sign_in_code.id
    )
    |> Repo.update_all(inc: [sign_in_attempts: 1])
    |> elem(0)
  end

  defp delete_sign_in_code(%__MODULE__{} = sign_in_code) do
    Repo.delete(sign_in_code)
  end

  defp mitigate_against_timing_attacks() do
    Bcrypt.no_user_verify()
  end
end
