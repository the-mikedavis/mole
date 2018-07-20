defmodule Mole.Accounts.User do
  @moduledoc "A user, including name and username"
  use Ecto.Schema
  import Ecto.Changeset
  alias Mole.Content.Survey

  schema "users" do
    field(:username, :string)
    field(:correct, :integer, default: 0)
    field(:incorrect, :integer, default: 0)
    field(:score, :integer, default: 0)
    field(:password, :string, virtual: true)
    field(:password_hash, :string)
    belongs_to(:survey, Survey)

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :username,
      :correct,
      :incorrect,
      :score,
      :password,
      :survey_id
    ])
    |> validate_required([:username])
    |> validate_length(:username, min: 3, max: 20)
    |> validate_length(:password, min: 6, max: 30)
    |> validate_number(:correct, greater_than: -1)
    |> validate_number(:incorrect, greater_than: -1)
    |> put_pass_hash()
  end

  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))

      _ ->
        changeset
    end
  end
end
