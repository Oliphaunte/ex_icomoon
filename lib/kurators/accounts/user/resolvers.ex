defmodule Kurators.Accounts.UserResolvers do
  alias Kurators.Accounts.User

  def fetch_all(_parent, _params, _resolution) do
    User.fetch_all()
  end

  # def find_user(_parent, %{id: id}, _resolution) do
  #   case Blog.Accounts.find_user(id) do
  #     nil ->
  #       {:error, "User ID #{id} not found"}
  #     user ->
  #       {:ok, user}
  #   end
  # end
end
