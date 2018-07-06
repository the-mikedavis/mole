defmodule Mole.Accounts do
  @moduledoc "Functions to act on accounts and credentials"
  alias Mole.Accounts.User
  alias Mole.Repo
  import Ecto.Query

  @correct_multiplier Application.get_env(:mole, :correct_mult)
  @incorrect_multiplier Application.get_env(:mole, :incorrect_mult)

  def get_user(id), do: Repo.get(User, id)

  def get_user!(id), do: Repo.get!(User, id)

  def list_users(), do: Repo.all(User)

  def change_user(%User{} = user), do: User.changeset(user, %{})

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def update_gameplay(user_id, correct?) do
    with user <- get_user(user_id),
         key <- if(correct?, do: :correct, else: :incorrect),
         changes <- Map.update!(user, key, &(&1 + 1)),
         changes <- %{changes | score: compute_score(changes)} do
      user
      |> Repo.preload(:credential)
      |> User.changeset(Map.from_struct(changes))
      |> Repo.update()
    end
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

  @doc "Check if a username is already taken in the repo."
  @spec username_exists?(String.t()) :: boolean()
  def username_exists?(username) do
    Repo.get_by(User, username: username) !== nil
  end

  # floor of 0
  defp compute_score(%{correct: correct, incorrect: incorrect}) do
    max(@correct_multiplier * correct - @incorrect_multiplier * incorrect, 0)
  end
end
