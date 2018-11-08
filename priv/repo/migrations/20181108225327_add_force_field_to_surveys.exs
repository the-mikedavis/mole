defmodule Mole.Repo.Migrations.AddForceFieldToSurveys do
  use Ecto.Migration

  def change do
    alter table(:surveys) do
      add(:force, :integer)
    end
  end
end
