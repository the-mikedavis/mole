defmodule MoleWeb.GameController do
  use MoleWeb, :controller

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
end
