defmodule Kurators.Repo.Migrations.CreateAuthTables do
  use Ecto.Migration

  def change do
    execute "CREATE SCHEMA IF NOT EXISTS auth", ""

    create table(:sign_in_codes, prefix: "auth", primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all, prefix: "accounts"), null: false
      add :hashed_code, :string, null: false
      add :sign_in_attempts, :integer, null: false, default: 0

      timestamps(updated_at: false)
    end

    create table(:tokens, prefix: "auth", primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all, prefix: "accounts"), null: false
      add :token, :text, null: false
      add :refresh_token, :text
      add :last_called_at, :utc_datetime, null: false
      add :context, :string, null: false

      timestamps(updated_at: false)
    end

    create unique_index(:tokens, [:user_id, :token], prefix: "auth")
  end
end
