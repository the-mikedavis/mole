defmodule Mole.Repo.Migrations.CreateSurveys do
  use Ecto.Migration

  def change do
    create table(:surveys) do
      add :slug, :string
      add :prelink, :string
      add :postlink, :string

      timestamps()
    end

    alter table(:users) do
      add :survey_id, references(:surveys)
    end
  end
end
