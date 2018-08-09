defmodule Mole.Accounts do
  use Private

  @moduledoc "Functions to act on accounts."
  alias Mole.{Accounts.User, Content.Survey, Repo}
  import Ecto.Query

  @correct_mult Application.get_env(:mole, :correct_mult)
  @incorrect_mult Application.get_env(:mole, :incorrect_mult)

  def get_user(id), do: Repo.get(User, id)

  def get_user!(id), do: Repo.get!(User, id)

  def get_users_by_survey(%Survey{id: id}) do
    from(
      u in User,
      join: s in assoc(u, :survey),
      where: s.id == ^id,
      select: u
    )
    |> Repo.all()
  end

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

  # give a 5 point bonus for getting all correct
  def save_gameplay(username, %{incorrect: 0, bonus: 0} = gameplay) do
    save_gameplay(username, Map.put(gameplay, :bonus, 5))
  end
  def save_gameplay(username, gameplay) do
    user = get_user_by_uname(username)

    new_scores = compute_score(user, gameplay)

    update_user(user, new_scores)
  end

  def get_user_by_uname(uname) do
    from(u in User, where: u.username == ^uname)
    |> Repo.one()
  end

  def authenticate_by_uname_and_pass(uname, given_pass) do
    user = get_user_by_uname(uname)

    cond do
      user && Comeonin.Bcrypt.checkpw(given_pass, user.password_hash) ->
        {:ok, user}

      user ->
        {:error, :unauthorized}

      true ->
        Comeonin.Bcrypt.dummy_checkpw()
        {:error, :not_found}
    end
  end

  @doc "Check if a username is already taken in the repo."
  @spec username_taken?(String.t()) :: boolean()
  def username_taken?(username),
    do: Repo.get_by(User, username: username) != nil

  @spec compute_score(%User{}, %{}) :: %{}
  defp compute_score(
    %User{score: s, incorrect: pi, correct: pc} = user,
    %{bonus: b, correct: c, incorrect: i}
  ) do
    user
    |> Map.from_struct()
    |> Map.put(:score, s + @correct_mult * c - @incorrect_mult * i + b)
    |> Map.put(:incorrect, pi + i)
    |> Map.put(:correct, pc + c)
  end
end
