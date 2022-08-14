defmodule <%= unless main_module = "Kurators", do: "#{main_module}." %>Kurators.Accounts.AuthResolvers do
  alias <%= unless main_module = "Kurators", do: "#{main_module}." %>Kurators.Auth

  def authenticate(_parent, %{email: email, context: context}, _resolution) do
    Auth.authenticate(email, context)
  end

  def authenticate(_parent, %{email: email}, _resolution) do
    Auth.authenticate(email)
  end
end
