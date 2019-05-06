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
    field(:force, :integer)
    has_many(:users, User, on_delete: :nilify_all)

    timestamps()
  end

  @doc false
  def changeset(survey, attrs) do
    survey
    |> cast(attrs, [:slug, :prelink, :postlink, :force])
    |> foreign_key_constraint(:users)
    |> validate_format(:slug, ~r/^[\w]*$/)
    |> validate_required([:slug])
    |> validate_inclusion(:force, 0..11)
  end
end
