defmodule Mole.Repo.Migrations.CreateSets do
  use Ecto.Migration

  def change do
    create table(:sets) do
      add :number, :integer

      timestamps()
    end

  end
end
