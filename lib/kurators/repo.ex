defmodule Kurators.Repo do
  use Ecto.Repo,
    otp_app: :kurators,
    adapter: Ecto.Adapters.Postgres
end
