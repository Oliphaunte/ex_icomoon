defmodule Kurators.Schema do
  use Absinthe.Schema

  import_types(Kurators.Accounts.UserTypes)

  query do
    import_fields(:user_queries)
  end

  # mutation do
  # end
end
