defmodule Kurators.Accounts.UserTypes do
  use Absinthe.Schema.Notation

  alias Kurators.Accounts.UserResolvers

  object :user do
    field(:email, :string)
    field(:secondary_email, :string)
    field(:username, :string)
    field(:first_name, :string)
    field(:middle_name, :string)
    field(:last_name, :string)
  end

  object :user_queries do
    @desc "Get all the users, optionally filtering"
    field :fetch_all, list_of(:user) do
      resolve(&UserResolvers.fetch_all/1)
    end

    @desc "Get user by id"
    field :get_user_by_id, :user do
      resolve(&UserResolvers.get_user_by_id/1)
    end

    @desc "Get user by email"
    field :get_user_by_email, :user do
      resolve(&UserResolvers.get_user_by_id/1)
    end
  end
end
