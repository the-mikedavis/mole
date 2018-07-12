defmodule MoleWeb.AdminController do
  use MoleWeb, :controller
  plug(MoleWeb.AdminAuth)

  alias Mole.Administrators

  def index(conn, _params) do
    users = Administrators.all()
    render(conn, "index.html", users: users)
  end

  def create(conn, %{"username" => username}) do
    Administrators.add(username)

    conn
    |> put_flash(:info, "Admin access for #{username} has been granted!")
    |> redirect(to: Routes.admin_path(conn, :index))
  end

  def delete(conn, %{"username" => username}) do
    Administrators.remove(username)

    conn
    |> put_flash(:info, "Admin access for #{username} has been revoked!")
    |> redirect(to: Routes.admin_path(conn, :index))
  end
end
