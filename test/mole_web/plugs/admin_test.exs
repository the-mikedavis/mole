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

    assert conn.assigns.admin? == false
  end

  test "trying with a non-admin user" do
    conn =
      build_conn()
      |> init_test_session(%{})
      |> fetch_flash()
      |> assign(:current_user, %User{username: "shakate"})
      |> Admin.call(%{})

    assert conn.assigns.admin? == false
  end

  test "trying with an administrator" do
    conn =
      build_conn()
      |> assign(:current_user, %User{username: "the-mikedavis"})
      |> Admin.call(%{})

    assert conn.assigns.admin? == true
  end
end
