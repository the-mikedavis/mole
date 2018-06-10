defmodule Mole.Accounts do
  alias Mole.Accounts.User
  alias Mole.Repo

  def get_user(id), do: Repo.get(User, id)

  def list_users(), do: Repo.all(User)

  def change_user(%User{} = user), do: User.changeset(user, %{})

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end
end
