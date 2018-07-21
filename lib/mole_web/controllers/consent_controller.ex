defmodule MoleWeb.ConsentController do
  use MoleWeb, :controller
  require Logger

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def agree(conn, _params) do
    # TODO... yeah
    Logger.debug("User consented.")
    text(conn, "Nice.")
  end
end
