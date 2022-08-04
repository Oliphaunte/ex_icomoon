defmodule Kurators.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    execute("CREATE SCHEMA IF NOT EXISTS inventory", "")

    create table(:items, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :item_number, :integer
      add :item_count, :integer
      add :status, :string

      timestamps()
    end

    create table(:orders, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string

      timestamps()
    end
  end
end
