defmodule Mole.Content.Survey do
  use Ecto.Schema
  import Ecto.Changeset


  schema "surveys" do
    field :link, :string
    field :slug, :string

    timestamps()
  end

  @doc false
  def changeset(survey, attrs) do
    survey
    |> cast(attrs, [:link, :slug])
    |> validate_required([:link, :slug])
  end
end
