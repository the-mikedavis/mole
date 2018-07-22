defmodule MoleWeb.GameController do
  use MoleWeb, :controller

  plug(:consent when action == :index)

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
