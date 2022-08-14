defmodule Kurators.Accounts.AuthTypes do
  use Absinthe.Schema.Notation

  alias Kurators.Accounts.AuthResolvers
  alias Kurators.Accounts.UserTypes

  object :auth_queries do
    @desc "Authenticate the user via an email"
    field :authenticate_email, :user do
      resolve(&AuthResolvers.authenticate/1)
    end

    @desc "Authenticate the user via a third-party"
    field :authenticate_third_party, :user do
      resolve(&AuthResolvers.authenticate/2)
    end
  end
end
