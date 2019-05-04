defmodule MoleWeb.Plugs.AdminTest do
  use MoleWeb.ConnCase, async: true
  import Plug.Test

  alias Mole.Accounts.Admin, as: AdminUser
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
      |> assign(:admin_id, 999)
      |> assign(:current_admin, %AdminUser{username: "shakate"})
      |> Admin.call(%{})

    assert conn.assigns.admin? == false
  end

  test "trying with an administrator" do
    conn =
      build_conn()
      |> assign(:admin_id, 1)
      |> assign(:current_admin, %AdminUser{username: "the-mikedavis"})
      |> Admin.call(%{})

    assert conn.assigns.admin? == true
  end
end
