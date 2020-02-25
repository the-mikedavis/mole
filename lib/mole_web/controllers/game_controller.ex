defmodule MoleWeb.GameController do
  use MoleWeb, :controller

  require Logger

  alias Mole.{Accounts, Content}
  alias MoleWeb.Plugs.Survey

  # order matters here
  plug(:logged_in)
  # removed for #42
  # plug(:consent)
  plug(:pre_survey when action == :index)
  plug(:learn)

  alias Mole.GameplayServer

  def index(conn, _params) do
    set_number = GameplayServer.set_number(conn.assigns.current_user.id) + 1

    render(conn, "index.html", set_number: set_number)
  end

  def show(%{assigns: %{current_user: user}} = conn, _params) do
    high_scores = Accounts.list_leaderboard()
    sets_left = GameplayServer.sets_left(user.id)

    with false <- Enum.any?(high_scores, &(&1.user_id == user.id)),
         0 <- sets_left,
         %{score: barrier_score} <- List.last(high_scores),
         true <- user.score > barrier_score do
      # show name entry page
      redirect(conn, to: Routes.game_path(conn, :enter_name))
    else
      # this user is already in the list of high scores
      # we don't lead them to the name entry page because they've already entered a name
      true ->
        # update their high score
        Accounts.upsert_high_score(%{user_id: user.id, score: user.score})
        # re-list the leaderboard, it changed (potentially)
        high_scores = Accounts.list_leaderboard()

        render(conn, "show.html", sets_left: sets_left, high_scores: high_scores)

      # there are sets left
      n when is_integer(n) and n > 0 ->
        render(conn, "show.html", sets_left: n, high_scores: high_scores)

      # list of high scores is empty
      nil ->
        # show name entry page
        redirect(conn, to: Routes.game_path(conn, :enter_name))

      # this user is not a high scorer :'(
      false ->
        render(conn, "show.html", sets_left: 0, high_scores: high_scores)
    end
  end

  def name_entry(%{assigns: %{current_user: user}} = conn, _params) do
    changeset = Accounts.change_high_score(%{user_id: user.id, score: user.score})

    render(conn, "enter_name.html", changeset: changeset)
  end

  def enter_name(%{assigns: %{current_user: user}} = conn, %{"high_score" => %{"name" => name}}) do
    %{user_id: user.id, score: user.score, name: name}
    |> Accounts.upsert_high_score()
    |> case do
      {:ok, _high_score} ->
        redirect(conn, to: Routes.game_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "enter_name.html", changeset: changeset)
    end
  end

  # ensure the user is logged in before they access a game
  defp logged_in(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      moniker = get_session(conn, :moniker)

      {:ok, user} = Accounts.create_user(%{moniker: moniker})

      conn
      |> put_session(:user_id_token, encrypt(conn, user.id))
      |> assign(:user_id, user.id)
      |> assign(:current_user, user)
      |> configure_session(renew: true)
    end
  end

  defp encrypt(conn, data), do: Phoenix.Token.sign(conn, MoleWeb.signing_token(), data)

  # defp consent(conn, _opts) do
  # if conn.assigns.survey_id && !conn.assigns.consent? do
  # conn
  # |> redirect(to: Routes.consent_path(conn, :index))
  # |> halt()
  # else
  # conn
  # end
  # end

  defp learn(conn, _opts) do
    if conn.assigns[:learned?] do
      conn
    else
      conn
      |> redirect(to: Routes.learning_path(conn, :show, 0))
      |> halt()
    end
  end

  defp pre_survey(conn, _opts) do
    with true <- Survey.pre_survey?(conn),
         %{prelink: prelink} <- Content.get_survey(conn.assigns.survey_id),
         link <- link(prelink, conn) do
      conn
      |> Survey.check()
      |> redirect(external: link)
      |> halt()
    else
      _ -> conn
    end
  end

  # build a link that gives the username and condition as query parameters
  defp link(link, %{assigns: %{current_user: user}}) do
    "#{link}?username=#{user.id}&condition=#{user.condition}"
  end
end
