defmodule Mole.Repo.Migrations.CreateSurveys do
  use Ecto.Migration

  def change do
    create table(:surveys) do
      add :link, :string
      add :slug, :string

      timestamps()
    end

  end
end
