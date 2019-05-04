defmodule Mole.Repo.Migrations.CreateHighScores do
  use Ecto.Migration

  def change do
    create table(:high_scores) do
      add :score, :integer
      add :name, :string
      add :user_id, :integer
    end
  end
end
