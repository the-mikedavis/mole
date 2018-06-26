defmodule Mole.Content.Image do
  @moduledoc """
  An image database object which stores the id it had from it's source,
  the path to itself, and whether or not it is malignant or not.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "images" do
    field(:malignant, :boolean, default: false)
    field(:origin_id, :string)
    field(:path, :string)

    timestamps()
  end

  @doc false
  def changeset(image, attrs) do
    image
    |> cast(attrs, [:origin_id, :path, :malignant])
    |> validate_required([:origin_id, :path, :malignant])
    |> unique_constraint(:origin_id)
  end
end
