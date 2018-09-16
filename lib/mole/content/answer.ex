defmodule Mole.Content.Answer do
  use Ecto.Schema
  import Ecto.Changeset


  schema "answers" do
    field :correct, :boolean, default: false
    field :user_id, :id
    field :image_id, :id

    timestamps()
  end

  @doc false
  def changeset(answer, attrs) do
    answer
    |> cast(attrs, [:correct])
    |> validate_required([:correct])
  end
end
