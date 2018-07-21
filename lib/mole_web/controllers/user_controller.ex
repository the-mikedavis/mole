defmodule MoleWeb.UserController do
  use MoleWeb, :controller
  plug(:authenticate when action in [:index, :show])

  alias Mole.{Accounts, Accounts.Leaderboard, Accounts.User}

  @page_size 20

  def index(conn, %{"offset" => offset}) do
    users = Leaderboard.get_block(@page_size, offset)
    pagination = Leaderboard.pagination(@page_size, offset)
    render(conn, "index.html", users: users, pagination: pagination)
  end

  def index(conn, _opts), do: index(conn, %{"offset" => 0})

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user(id)
    render(conn, "show.html", user: user)
  end

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> MoleWeb.Plugs.Auth.login(user)
        |> put_flash(:info, "#{user.username} created!")
        |> redirect(to: Routes.user_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def taken(conn, %{"value" => username}),
    do: json(conn, %{taken: Accounts.username_taken?(username)})

  defp authenticate(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end
end
