defmodule Mole.Repo.Migrations.AddSurveyProgress do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :survey_progress, :integer
    end
  end
end
