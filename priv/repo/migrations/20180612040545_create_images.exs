defmodule Mole.Repo.Migrations.CreateImages do
  use Ecto.Migration

  def change do
    create table(:images) do
      add :origin_id, :string
      add :malignant, :boolean, default: false, null: false
      add :type, :string

      timestamps()
    end

    create unique_index(:images, [:origin_id])
  end
end
