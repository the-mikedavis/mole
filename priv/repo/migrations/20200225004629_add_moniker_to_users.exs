defmodule Mole.Repo.Migrations.AddMonikerToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :moniker, :string
    end
  end
end
