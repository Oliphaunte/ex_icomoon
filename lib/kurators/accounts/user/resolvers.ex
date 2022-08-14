defmodule Kurators.Accounts.UserResolvers do
  alias Kurators.Accounts.User

  def fetch_all(_parent, _params, _resolution) do
    User.fetch_all()
  end

  def get_user_by_id(_parent, %{id: id}, _resolution) do
    case User.get_user_by_id(id) do
      nil ->
        {:error, "User ID #{id} not found"}

      user ->
        {:ok, user}
    end
  end

  def get_user_by_email(_parent, %{email: email}, _resolution) do
    case User.get_user_by_email(email) do
      nil ->
        {:error, "User ID #{email} not found"}

      user ->
        {:ok, user}
    end
  end
end
