defmodule Mole.Content.Survey do
  use Ecto.Schema
  import Ecto.Changeset
  alias Mole.Accounts.User

  @moduledoc """
  Surveys, which have many users, keep track of links to qualtrics. Surveys
  are joinable by the /join/:survey_slug endpoint.
  """

  schema "surveys" do
    field(:postlink, :string)
    field(:prelink, :string)
    field(:slug, :string)
    has_many(:users, User)

    timestamps()
  end

  @doc false
  def changeset(survey, attrs) do
    survey
    |> cast(attrs, [:slug, :prelink, :postlink])
    |> validate_format(:slug, ~r/^[\w]*$/)
    |> validate_required([:slug])
  end
end
