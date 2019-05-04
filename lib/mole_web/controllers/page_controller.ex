defmodule MoleWeb.PageController do
  use MoleWeb, :controller

  alias Mole.Accounts

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def leaderboard(conn, _params) do
    scores = Accounts.list_leaderboard()

    render(conn, "leaderboard.html", scores: scores)
  end
end
