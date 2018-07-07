defmodule MoleWeb.SessionController do
  use MoleWeb, :controller

  def new(conn, _), do: render(conn, "new.html")

  def create(conn, %{"session" => %{"username" => uname, "password" => pass}}) do
    case MoleWeb.Auth.login_by_uname_and_pass(conn, uname, pass) do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "Invalid username/password combination")
        |> render("new.html")
    end
  end

  def delete(conn, _) do
    conn
    |> MoleWeb.Auth.logout()
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
