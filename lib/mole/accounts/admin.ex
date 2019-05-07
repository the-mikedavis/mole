defmodule Mole.Accounts.Admin do
  @moduledoc "A user, including name and username, capable of administrating the app"
  use Ecto.Schema
  import Ecto.Changeset

  schema "admins" do
    field(:username, :string)
    field(:password, :string, virtual: true)
    field(:password_hash, :string)

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, ~w(username password)a)
    |> validate_required(~w(username)a)
    |> unique_constraint(:username)
    |> validate_length(:username, min: 3, max: 10)
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
