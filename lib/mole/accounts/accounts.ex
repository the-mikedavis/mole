defmodule Mole.Accounts do
  alias Mole.Accounts.User
  alias Mole.Repo
  import Ecto.Query

  def get_user(id), do: Repo.get(User, id)

  def list_users(), do: Repo.all(User)

  def change_user(%User{} = user), do: User.changeset(user, %{})

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def register_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def get_user_by_email(email) do
    from(u in User, join: c in assoc(u, :credential), where: c.email == ^email)
    |> Repo.one()
    |> Repo.preload(:credential)
  end

  def authenticate_by_email_and_pass(email, given_pass) do
    user = get_user_by_email(email)

    cond do
      user && Comeonin.Bcrypt.checkpw(given_pass, user.credential.password_hash) ->
        {:ok, user}

      user ->
        {:error, :unauthorized}

      true ->
        Comeonin.Bcrypt.dummy_checkpw()
        {:error, :not_found}
    end
  end
end
