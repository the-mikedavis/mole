defmodule Mole.Content.Answer do
  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc """
  Answers are only recorded for the survey users.

  They keep track of a user and an image, and whether or not the user was
  correct for that image.
  """

  schema "answers" do
    field(:correct, :boolean, default: false)
    field(:user_id, :id)
    field(:image_id, :id)
    field(:time_spent, :integer)

    timestamps()
  end

  @doc false
  def changeset(answer, attrs) do
    answer
    |> cast(attrs, [:correct, :time_spent])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:image_id)
    |> validate_required([:correct])
  end
end
