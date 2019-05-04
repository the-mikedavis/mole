defmodule Mole.Accounts.HighScore do
  @moduledoc "A high score to be put in the leaderboard"
  use Ecto.Schema
  import Ecto.Changeset

  schema "high_scores" do
    field(:name, :string)
    field(:score, :integer)
    field(:user_id, :integer)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, ~w(name score user_id)a)
    |> validate_required(~w(name score user_id)a)
    |> validate_length(:name, min: 3, max: 10)
    |> validate_number(:score, greater_than: -1)
  end
end
