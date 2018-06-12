defmodule Mole.Content.Image do
  use Ecto.Schema
  import Ecto.Changeset

  schema "images" do
    field :malignant, :boolean, default: false
    field :origin_id, :string
    field :path, :string

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
