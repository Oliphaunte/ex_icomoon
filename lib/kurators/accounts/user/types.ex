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
    field :users, list_of(:user) do
      resolve(&UserResolvers.fetch_all/3)
    end

    @desc "Get a user using criteria"
    field :user, :user do
    end
  end
end
