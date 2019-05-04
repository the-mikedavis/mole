defmodule Mole.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :correct, :integer
      add :incorrect, :integer
      add :score, :integer
      add :condition, :integer
      add :survey_progress, :integer

      timestamps()
    end
  end
end
