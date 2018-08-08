defmodule MoleWeb.UserController do
  use MoleWeb, :controller
  plug(:authenticate when action in [:index, :show])

  alias Mole.{Accounts, Accounts.Leaderboard, Accounts.User}

  @page_size 20

  def index(conn, %{"page" => page}) do
    offset = (String.to_integer(page) - 1) * @page_size

    with [] <- Leaderboard.get_block(@page_size, offset) do
      conn
      |> put_status(:not_found)
      |> put_view(MoleWeb.ErrorView)
      |> render(:"404")
    else
      users ->
        pagination = Leaderboard.pagination(@page_size, offset)
        render(conn, "index.html", users: users, pagination: pagination)
    end
  end

  def index(conn, _opts), do: index(conn, %{"page" => "1"})

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
        # don't halt, this might actually go somewhere. just kinda meh
        |> redirect(to: Routes.game_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  # def taken(conn, %{"value" => username}),
  #   do: json(conn, %{taken: Accounts.username_taken?(username)})

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
