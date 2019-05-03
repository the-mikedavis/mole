defmodule MoleWeb.Plugs.Auth do
  @moduledoc false
  import Plug.Conn

  alias Mole.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)
    user = user_id && Accounts.get_user(user_id)

    admin_id = get_session(conn, :admin_id)
    admin = admin_id && Accounts.get_admin(admin_id)

    conn
    |> assign(:user_id, user_id)
    |> assign(:current_user, user)
    |> assign(:admin_id, admin_id)
    |> assign(:current_admin, admin)
  end

  def login_by_uname_and_pass(conn, uname, given_pass) do
    case Accounts.authenticate_by_uname_and_pass(uname, given_pass) do
      {:ok, user} ->
        {:ok, login(conn, user)}

      {:error, :unauthorized} ->
        {:error, :unauthorized, conn}

      {:error, :not_found} ->
        {:error, :not_found, conn}
    end
  end

  def login(conn, user) do
    conn
    |> assign(:current_admin, user)
    |> put_session(:admin_id, user.id)
    |> configure_session(renew: true)
  end

  def logout(conn), do: configure_session(conn, drop: true)
end
