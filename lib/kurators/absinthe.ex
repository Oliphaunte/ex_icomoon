defmodule Kurators.Schema do
  use Absinthe.Schema

  import_types(Kurators.Accounts.UserTypes)
  import_types(Kurators.Accounts.AuthTypes)

  query do
    import_fields(:user_queries)
    import_fields(:auth_queries)
  end

  # mutation do
  # end
end
