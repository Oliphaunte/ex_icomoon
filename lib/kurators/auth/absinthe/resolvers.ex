defmodule Kurators.Accounts.AuthResolvers do
  alias Kurators.Auth

  def authenticate(_parent, %{email: email, context: context}, _resolution) do
    Auth.authenticate(email, context)
  end

  def authenticate(_parent, %{email: email}, _resolution) do
    Auth.authenticate(email)
  end
end
