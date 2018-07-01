defmodule Mole.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :username, :string, null: false
      add :correct, :integer
      add :incorrect, :integer
      add :score, :integer

      timestamps()
    end

    create unique_index(:users, [:username])
  end
end
