defmodule Mole.Content.Survey do
  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc "The Survey context, which keeps track of survey links."

  schema "surveys" do
    # external link to qualtrics or whatever
    field(:link, :string)
    # internally identifiable slug
    field(:slug, :string)

    timestamps()
  end

  @doc false
  def changeset(survey, attrs) do
    survey
    |> cast(attrs, [:link, :slug])
    |> validate_required([:link, :slug])
  end
end
