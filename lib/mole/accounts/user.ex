defmodule Mole.Accounts.User do
  @moduledoc "A user, temporary given the cookie/session"
  use Ecto.Schema
  import Ecto.Changeset
  alias Mole.Content.{Answer, Survey}

  schema "users" do
    field(:correct, :integer, default: 0)
    field(:incorrect, :integer, default: 0)
    field(:score, :integer, default: 0)
    field(:condition, :integer)
    field(:survey_progress, :integer)
    belongs_to(:survey, Survey)
    has_many(:answers, Answer)
    field(:moniker, :string)

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :correct,
      :incorrect,
      :score,
      :survey_id,
      :condition,
      :survey_progress,
      :moniker
    ])
    |> foreign_key_constraint(:survey_id)
    |> validate_number(:correct, greater_than: -1)
    |> validate_number(:incorrect, greater_than: -1)
  end
end
