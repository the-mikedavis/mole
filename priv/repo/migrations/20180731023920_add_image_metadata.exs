defmodule Mole.Repo.Migrations.AddImageMetadata do
  use Ecto.Migration

  def change do
    alter table(:images) do
      add :data, :map
    end
  end
end
