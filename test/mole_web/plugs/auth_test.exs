defmodule MoleWeb.Plugs.AuthTest do
  use MoleWeb.ConnCase, async: true
  import Plug.Test

  alias Mole.Accounts
  alias MoleWeb.Plugs.Auth

  def user_fixture(attrs \\ %{}) do
    {:ok, user} = Accounts.create_admin(attrs)

    user
  end

  test "init returns whatever it got" do
    assert Auth.init(nil) == nil
    assert Auth.init(47) == 47
    assert Auth.init(%{}) == %{}
  end

  test "logging in on a valid user" do
    user = user_fixture(%{username: "username", password: "password"})

    conn =
      build_conn()
      |> init_test_session(%{})
      |> fetch_flash()

    assert {:ok, login} = Auth.login_by_uname_and_pass(conn, "username", "password")

    assert get_session(login, :admin_id) == user.id
    assert login.assigns.current_admin.id == user.id
    assert login.private.plug_session_info == :renew
  end

  test "logging in a user, wrong password" do
    user_fixture(%{username: "username", password: "password"})

    conn =
      build_conn()
      |> init_test_session(%{})
      |> fetch_flash()

    assert {:error, :unauthorized, ^conn} =
             Auth.login_by_uname_and_pass(conn, "username", "wrongpassword")
  end

  test "logging in, wrong user" do
    user_fixture(%{username: "username", password: "password"})

    conn =
      build_conn()
      |> init_test_session(%{})
      |> fetch_flash()

    assert {:error, :not_found, ^conn} =
             Auth.login_by_uname_and_pass(
               conn,
               "wrongusername",
               "wrongpassword"
             )
  end

  test "logging out" do
    user_fixture(%{username: "username", password: "password"})

    conn =
      build_conn()
      |> init_test_session(%{})
      |> fetch_flash()

    assert {:ok, login} = Auth.login_by_uname_and_pass(conn, "username", "password")

    assert Auth.logout(login).private.plug_session_info == :drop
  end
end
