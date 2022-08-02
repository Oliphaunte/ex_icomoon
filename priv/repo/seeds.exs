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

alias Kurators.Accounts.{Organization, User, Role, Status}

{:ok, app_name} = :application.get_application(Kurators)
primary_email = Application.get_env(:kurators, :primary_email)

Organization.create(%{name: Atom.to_string(app_name)})

for role <- ["admin", "user"] do
  {:ok, _} = Role.create(%{name: role, default: true})
end

for status <- ["active", "inactive", "suspended"] do
  {:ok, _} = Status.create(%{name: status, default: true})
end

{:ok, organization} = Organization.get_by_name(Atom.to_string(app_name))
{:ok, role_admin} = Role.get_by_name("admin")
{:ok, status_active} = Status.get_by_name("active")

User.create(%{
  email: primary_email,
  statuses_id: status_active.id,
  roles_id: role_admin.id,
  organizations_id: organization.id
})
