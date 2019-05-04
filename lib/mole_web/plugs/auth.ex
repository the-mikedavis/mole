defmodule MoleWeb.Plugs.Auth do
  @moduledoc false
  import Plug.Conn

  alias Mole.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    conn =
      with token when is_binary(token) <- get_session(conn, :user_id_token),
           {:ok, user_id} <- decrypt(conn, token),
           user <- Accounts.get_user(user_id) do
        conn
        |> assign(:user_id, user_id)
        |> assign(:current_user, user)
      else
        _ -> conn
      end

    with token when is_binary(token) <- get_session(conn, :admin_id_token),
         {:ok, admin_id} <- decrypt(conn, token),
         admin <- Accounts.get_admin(admin_id) do
      conn
      |> assign(:admin_id, admin_id)
      |> assign(:current_admin, admin)
    else
      _ -> conn
    end
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
    |> put_session(:admin_id_token, encrypt(conn, user.id))
    |> configure_session(renew: true)
  end

  def logout(conn), do: configure_session(conn, drop: true)

  defp encrypt(conn, data), do: Phoenix.Token.sign(conn, MoleWeb.signing_token(), data)
  # two weeks
  defp decrypt(conn, data),
    do: Phoenix.Token.verify(conn, MoleWeb.signing_token(), data, max_age: 1_209_600)
end
