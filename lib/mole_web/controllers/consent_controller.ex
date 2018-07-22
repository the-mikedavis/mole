defmodule MoleWeb.ConsentController do
  use MoleWeb, :controller
  require Logger

  alias MoleWeb.Plugs.{Condition, Consent}

  def index(conn, _params), do: render(conn, "index.html")

  def agree(conn, _params) do
    conn
    |> Consent.consent()
    |> Condition.put_random()
    |> redirect(to: Routes.game_path(conn, :index))
  end
end
