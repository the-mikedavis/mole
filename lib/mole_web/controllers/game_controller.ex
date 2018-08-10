defmodule MoleWeb.GameController do
  use MoleWeb, :controller

  require Logger

  alias Mole.Content
  alias MoleWeb.Plugs.Survey

  # ensure the user is logged in and consents
  plug(:logged_in)
  plug(:consent)
  plug(:learn)

  # route to the surveys
  plug(:pre_survey when action == :index)
  plug(:post_survey when action == :show)

  alias Mole.GameplayServer

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def show(conn, _params) do
    sets_left = GameplayServer.sets_left(conn.assigns.current_user.username)

    render(conn, "show.html", sets_left: sets_left)
  end

  # ensure the user is logged in before they access a game
  defp logged_in(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> redirect(to: Routes.user_path(conn, :new))
      |> halt()
    end
  end

  defp consent(conn, _opts) do
    if conn.assigns.survey_id && !conn.assigns.consent? do
      conn
      |> redirect(to: Routes.consent_path(conn, :index))
      |> halt()
    else
      conn
    end
  end

  defp learn(conn, _opts) do
    if !conn.assigns[:learned?] do
      conn
      |> redirect(to: Routes.learning_path(conn, :show, 0))
      |> halt()
    else
      conn
    end
  end

  defp pre_survey(conn, _opts) do
    if Survey.pre_survey?(conn) do
      survey = Content.get_survey!(conn.assigns.survey_id)
      link = "#{survey.prelink}?username=#{conn.assigns.current_user.username}"

      conn
      |> Survey.check()
      |> redirect(external: link)
      |> halt()
    else
      conn
    end
  end

  defp post_survey(conn, _opts) do
    if Survey.post_survey?(conn) do
      survey = Content.get_survey!(conn.assigns.survey_id)
      link = "#{survey.postlink}?username=#{conn.assigns.current_user.username}"

      conn
      |> Survey.check()
      |> redirect(external: link)
      |> halt()
    else
      conn
    end
  end
end
