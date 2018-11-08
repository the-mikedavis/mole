defmodule Mole.Content.Set do
  use Ecto.Schema
  import Ecto.Changeset
  alias Mole.Content.Image

  @moduledoc """
  There are 4 sets, each with 12 images. The set numbers are constant.
  The images in each set are constant.
  """

  schema "sets" do
    field(:number, :integer)
    has_many(:images, Image)

    timestamps()
  end

  @doc false
  def changeset(set, attrs) do
    set
    |> cast(attrs, [:number])
    |> validate_required([:number])
  end
end
