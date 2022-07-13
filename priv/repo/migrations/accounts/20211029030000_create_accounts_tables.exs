defmodule Kurators.Repo.Migrations.CreateAccountsTables do
  use Ecto.Migration

  def change do
    execute "CREATE SCHEMA IF NOT EXISTS accounts", ""
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:accounts, prefix: "accounts", primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:name, :string, null: false)

      timestamps()
    end

    create(unique_index(:accounts, [:name], prefix: "accounts"))

    create table(:users, prefix: "accounts", primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :citext, null: false
      add :secondary_email, :citext
      add :username, :string
      add :first_name, :string
      add :middle_name, :string
      add :last_name, :string
      add :profile_picture, :string
      add :confirmed_at, :utc_datetime
      add :role, :map
      add :status, :map

      add(:accounts_id, references(:accounts, type: :binary_id, on_delete: :delete_all),
        null: false
      )

      timestamps()
    end

    create unique_index(:users, [:email], prefix: "accounts")
  end
end
