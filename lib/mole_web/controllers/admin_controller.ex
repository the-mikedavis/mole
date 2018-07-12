defmodule MoleWeb.AdminController do
  use MoleWeb, :controller
  plug(:authenticate)

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

  defp authenticate(conn, _opts) do
    with %{username: username} <- conn.assigns.current_user,
         true <- Administrators.is?(username) do
      conn
    else
      _ ->
        conn
        |> put_flash(
          :error,
          "You do not have proper permissions to access that page."
        )
        |> redirect(to: Routes.session_path(conn, :index))
        |> halt()
    end
  end
end
