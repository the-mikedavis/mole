defmodule MoleWeb.AdminController do
  use MoleWeb, :controller
  plug(:admin)

  alias MoleWeb.Router.Helpers, as: Routes
  alias Mole.Accounts

  def index(conn, _params) do
    users = Accounts.list_admins()
    new_admin = Accounts.change_admin()

    render(conn, "index.html", users: users, new_admin: new_admin)
  end

  def create(conn, %{"admin" => %{"username" => username}}) do
    case Accounts.create_admin(%{username: username, password: default_password()}) do
      {:ok, _admin} ->
        conn
        |> put_flash(
          :info,
          "Admin \"#{username}\" has been created with default password \"#{default_password()}\""
        )
        |> redirect(to: Routes.admin_path(conn, :index))

      {:error, changeset} ->
        users = Accounts.list_admins()

        conn
        |> put_flash(:error, "Could not create admin \"#{username}\"! See changes below")
        |> render("index.html", users: users, new_admin: changeset)
    end
  end

  def edit(conn, _params) do
    admin = Accounts.get_admin!(conn.assigns.admin_id)
    changeset = Accounts.change_admin(admin)
    render(conn, "edit.html", admin: admin, changeset: changeset)
  end

  def update(conn, %{"id" => id, "admin" => admin_params}) do
    admin = Accounts.get_admin!(id)

    case Accounts.update_admin(admin, Map.delete(admin_params, "username")) do
      {:ok, _admin} ->
        conn
        |> put_flash(:info, "Password updated.")
        |> redirect(to: Routes.admin_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Could not change user! See errors below.")
        |> render(conn, "edit.html", changeset: changeset, admin: admin)
    end
  end

  def delete(conn, %{"username" => username}) do
    username
    |> Accounts.remove_admin()
    |> case do
      :ok ->
        put_flash(conn, :info, "Admin access for \"#{username}\" has been revoked!")

      :error ->
        put_flash(conn, :error, "Admin access could not be revoked for user \"#{username}\".")
    end
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

  defp default_password, do: Application.fetch_env!(:mole, :default_password)
end
