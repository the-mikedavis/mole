defmodule Mole.Repo.Migrations.CreateAnswers do
  use Ecto.Migration

  def change do
    create table(:answers) do
      add :correct, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :nothing)
      add :image_id, references(:images, on_delete: :nothing)
      add :time_spent, :integer

      timestamps()
    end

    create index(:answers, [:user_id])
    create index(:answers, [:image_id])
  end
end
