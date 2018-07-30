defmodule MoleWeb.Plugs.AdminTest do
  use MoleWeb.ConnCase, async: true
  import Plug.Test

  alias Mole.Accounts.User
  alias MoleWeb.Plugs.Admin

  test "init returns whatever it got" do
    assert Admin.init(nil) == nil
    assert Admin.init(47) == 47
    assert Admin.init(%{}) == %{}
  end

  test "trying without a current user" do
    conn =
      build_conn()
      |> init_test_session(%{})
      |> fetch_flash()
      |> Admin.call(%{})

    assert conn.halted
    assert redirected_to(conn) =~ "session"

    assert get_flash(conn) ==
             %{
               "error" =>
                 "You do not have proper permissions to access that page."
             }
  end

  test "trying with a non-admin user" do
    conn =
      build_conn()
      |> init_test_session(%{})
      |> fetch_flash()
      |> assign(:current_user, %User{username: "shakate"})
      |> Admin.call(%{})

    assert conn.halted
    assert redirected_to(conn) =~ "session"

    assert get_flash(conn) ==
             %{
               "error" =>
                 "You do not have proper permissions to access that page."
             }
  end

  test "trying with an administrator" do
    conn = assign(build_conn(), :current_user, %User{username: "the-mikedavis"})

    assert conn == Admin.call(conn, %{})
  end
end
