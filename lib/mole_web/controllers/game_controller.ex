defmodule MoleWeb.GameController do
  use MoleWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
