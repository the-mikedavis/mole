defmodule MoleWeb.AdminController do
  use MoleWeb, :controller
  plug(MoleWeb.Plugs.Admin)

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
    message =
      case Administrators.remove(username) do
        :ok -> "Admin access for #{username} has been revoked!"
        :error -> "Admin access could not be revoked for this user."
      end

    conn
    |> put_flash(:info, message)
    |> redirect(to: Routes.admin_path(conn, :index))
  end
end
