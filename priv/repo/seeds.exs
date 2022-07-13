# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Kurators.Repo.insert!(%Kurators.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Kurators.Accounts

{:ok, app_name} = :application.get_application(Kurators)

Accounts.create_account(%{name: Atom.to_string(app_name)})
