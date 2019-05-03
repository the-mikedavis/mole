defmodule MoleWeb.AdminController do
  use MoleWeb, :controller
  plug(:admin)

  @default_password Application.fetch_env!(:mole, :default_password)

  alias MoleWeb.Router.Helpers, as: Routes
  alias Mole.Accounts

  def index(conn, _params) do
    users = Accounts.list_admins()
    new_admin = Accounts.change_admin()

    render(conn, "index.html", users: users, new_admin: new_admin)
  end

  def create(conn, %{"username" => username}) do
    case Accounts.create_admin(%{username: username, password: @default_password}) do
      {:ok, _admin} ->
        conn
        |> put_flash(:info, "Admin #{username} has been created with default password \"#{@default_password}\"")
        |> redirect(to: Routes.admin_path(conn, :index))

      {:error, changeset} ->
        users = Accounts.list_admins()

        conn
        |> put_flash(:error, "Could not create #{username} admin! See changes below")
        |> render("index.html", users: users, new_admin: changeset)
    end
  end

  def delete(conn, %{"username" => username}) do
    message =
      case Accounts.remove_admin(username) do
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
