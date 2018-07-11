defmodule MoleWeb.GameController do
  use MoleWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def show(conn, _params) do
    # render(conn, "show.html", gameplay: conn.assigns.gameplay)
    render(conn, "show.html")
  end
end
