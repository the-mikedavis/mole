defmodule MoleWeb.GameController do
  use MoleWeb, :controller

  # ensure the user is logged in and consents
  plug(:logged_in)
  plug(:consent)

  alias Mole.GameplayServer

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def show(conn, _params) do
    case GameplayServer.get_done(conn.assigns.current_user.username) do
      nil ->
        redirect(conn, to: "/play")

      gameplay ->
        render(conn, "show.html", gameplay: gameplay)
    end
  end

  # ensure the user is logged in before they access a game
  defp logged_in(conn, _opts) do
    if conn.assigns.current_user do
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
end
