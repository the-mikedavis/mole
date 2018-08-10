defmodule MoleWeb.AdminController do
  use MoleWeb, :controller
  plug(:admin)

  alias MoleWeb.Router.Helpers, as: Routes
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

  defp admin(conn, _opts) do
    if conn.assigns[:admin?] do
      conn
    else
      conn
      |> put_flash(
        :error,
        "You do not have proper permissions to access that page."
      )
      |> redirect(to: Routes.session_path(conn, :new))
      |> halt()
    end
  end
end
