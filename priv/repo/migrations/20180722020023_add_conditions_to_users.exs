defmodule Mole.Repo.Migrations.AddConditionsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :condition, :integer
    end
  end
end
