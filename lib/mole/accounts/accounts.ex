defmodule Mole.Accounts do
  use Private

  @moduledoc "Functions to act on accounts."
  alias Mole.{Accounts.User, Accounts.Admin, Accounts.HighScore, Content, Content.Survey, Repo}
  import Ecto.Query

  @correct_mult Application.get_env(:mole, :correct_mult)
  @incorrect_mult Application.get_env(:mole, :incorrect_mult)
  @leaderboard_limit Application.fetch_env!(:mole, :leaderboard_limit)

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

  def get_user_with_answers(id) do
    from(
      u in User,
      select: u,
      where: [id: ^id],
      preload: [:answers]
    )
    |> Repo.one()
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

  # 60 seconds * 60 minutes * 24 hours * 31 days
  @one_month 60 * 60 * 24 * 31

  def cull_users do
    now = NaiveDateTime.utc_now()

    User
    |> Repo.all()
    |> Enum.filter(fn user -> NaiveDateTime.diff(now, user.updated_at) > @one_month end)
    |> Enum.each(&Repo.delete/1)
  end

  # give a 5 point bonus for getting all correct
  def save_gameplay(username, %{incorrect: 0, bonus: 0} = gameplay) do
    save_gameplay(username, Map.put(gameplay, :bonus, 5))
  end

  def save_gameplay(username, gameplay) do
    user = get_user_by_uname(username)

    new_scores = compute_score(user, gameplay)

    if user.survey_progress in [0, 1], do: Content.save_answers(gameplay, user)

    update_user(user, new_scores)
  end

  def get_user_by_uname(uname) do
    from(u in User, where: u.username == ^uname)
    |> Repo.one()
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

  # Admins

  def list_admins(), do: Repo.all(Admin)

  def get_admin(id), do: Repo.get(Admin, id)
  def get_admin!(id), do: Repo.get!(Admin, id)

  def create_admin(attrs \\ %{}) do
    %Admin{}
    |> Admin.changeset(attrs)
    |> Repo.insert()
  end

  def update_admin(%Admin{} = admin, params) do
    admin
    |> Admin.changeset(params)
    |> Repo.update()
  end

  def change_admin(%Admin{} = user \\ %Admin{}), do: Admin.changeset(user, %{})

  @spec remove_admin(String.t()) :: :ok | :error
  def remove_admin("the-mikedavis"), do: :error

  def remove_admin(username) do
    with %Admin{} = admin <- Repo.get_by(Admin, username: username),
         {:ok, _struct} <- Repo.delete(admin) do
      :ok
    else
      nil -> :error

      {:error, _reason} -> :error
    end
  end

  @spec is_admin?(integer()) :: boolean()
  def is_admin?(id) do
    case Repo.get(Admin, id) do
      nil -> false
      _admin -> true
    end
  end

  def authenticate_by_uname_and_pass(uname, given_pass) do
    user = Repo.get_by(Admin, username: uname)

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

  # leaderboard stuff

  def list_leaderboard do
    from(
      s in HighScore,
      select: s,
      order_by: s.score,
      limit: @leaderboard_limit
    )
    |> Repo.all()
  end

  # upsert the highscore based on the user id
  def create_high_score(%{} = attrs) do
    HighScore
    |> Repo.get_by(user_id: attrs[:user_id])
    |> case do
      %HighScore{} = hs -> hs
      nil -> %HighScore{}
    end
    |> HighScore.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Remove old high scores when they're replaced by newer ones.

  Meant to be called periodically.
  """
  def cull_high_scores do
    HighScore
    |> Repo.all()
    |> Enum.drop(@leaderboard_limit)
    |> Enum.each(&Repo.delete/1)
  end
end
