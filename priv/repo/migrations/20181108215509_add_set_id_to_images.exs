defmodule Mole.Repo.Migrations.AddSetIdToImages do
  use Ecto.Migration

  def change do
    alter table(:images) do
      add(:set_id, references(:sets))
    end
  end
end
