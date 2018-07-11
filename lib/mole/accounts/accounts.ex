defmodule Mole.Accounts do
  @moduledoc "Functions to act on accounts."
  alias Mole.Accounts.User
  alias Mole.Repo
  import Ecto.Query
  require Logger

  @correct_mult Application.get_env(:mole, :correct_mult)
  @incorrect_mult Application.get_env(:mole, :incorrect_mult)

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

  def save_gameplay(username, gameplay) do
    with user <- get_user_by_uname(username),
         total_gameplay <- total_gameplay(user, gameplay),
         new_scores <- compute_score(total_gameplay),
         do: update_user(user, new_scores)

    Logger.info("Saved gameplay for user #{username}.")
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
  @spec username_exists?(String.t()) :: boolean()
  def username_exists?(username) do
    Repo.get_by(User, username: username) !== nil
  end

  # floor of 0
  defp compute_score(%{correct: correct, incorrect: incorrect} = gameplay) do
    Map.put(
      gameplay,
      :score,
      @correct_mult * correct - @incorrect_mult * incorrect
    )
  end

  defp total_gameplay(%User{} = user, gameplay) do
    {correct, incorrect} =
      Enum.reduce(gameplay.played, {0, 0}, fn image, {cor, incor} ->
        if image.correct?, do: {cor + 1, incor}, else: {cor, incor + 1}
      end)

    %{
      correct: user.correct + correct,
      incorrect: user.incorrect + incorrect
    }
  end
end
