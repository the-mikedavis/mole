defmodule MoleWeb.ConsentController do
  use MoleWeb, :controller
  require Logger

  alias MoleWeb.Plugs.Consent

  def index(conn, _params), do: render(conn, "index.html")

  def agree(conn, _params) do
    conn
    |> Consent.consent()
    |> redirect(to: Routes.game_path(conn, :index))
  end
end
