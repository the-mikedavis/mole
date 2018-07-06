defmodule Mole.Accounts.User do
  @moduledoc "A user, including name and username"
  use Ecto.Schema
  import Ecto.Changeset
  alias Mole.Accounts.Credential

  schema "users" do
    field(:name, :string)
    field(:username, :string)
    field(:correct, :integer, default: 0)
    field(:incorrect, :integer, default: 0)
    field(:score, :integer, default: 0)
    has_one(:credential, Credential)

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :username, :correct, :incorrect, :score])
    |> validate_required([:name, :username])
    |> validate_length(:username, min: 1, max: 20)
    |> validate_number(:correct, greater_than: -1)
    |> validate_number(:incorrect, greater_than: -1)
    |> validate_number(:score, greater_than: -1)
  end

  def registration_changeset(user, params) do
    user
    |> changeset(params)
    |> Ecto.Changeset.cast_assoc(:credential, with: &Credential.changeset/2)
  end
end
