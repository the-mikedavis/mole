defmodule MoleWeb.Plugs.ConditionTest do
  use MoleWeb.ConnCase, async: true
  import Plug.Test

  alias Mole.Accounts.User
  alias MoleWeb.Plugs.Condition

  test "init returns whatever it got" do
    assert Condition.init(nil) == nil
    assert Condition.init(47) == 47
    assert Condition.init(%{}) == %{}
  end

  # TODO change this to be feedback yes learning none
  test "a conn without a user has no condition" do
    conn =
      build_conn()
      |> init_test_session(%{})
      |> fetch_flash()
      |> Condition.call(%{})

    assert conn.assigns.condition == nil
  end

  test "a conn with a user with no condition has a condition" do
    conn =
      build_conn()
      |> init_test_session(%{})
      |> fetch_flash()
      |> assign(:current_user, %User{condition: nil})
      |> put_session(:condition, 1)
      |> Condition.call(%{})

    assert is_integer(conn.assigns.condition)
  end

  test "a conn with a user has a condition" do
    conn =
      build_conn()
      |> init_test_session(%{})
      |> fetch_flash()
      |> assign(:current_user, %User{condition: 1})
      |> Condition.call(%{})

    assert conn.assigns.condition == 1
  end

  test "putting a random condition" do
    conn =
      build_conn()
      |> init_test_session(%{})
      |> fetch_flash()
      |> Condition.put_random()

    assert is_integer(conn.assigns.condition)
  end

  test "putting a random when there is one doesn't do anything" do
    conn =
      build_conn()
      |> init_test_session(%{})
      |> fetch_flash()
      |> assign(:condition, 5)
      |> Condition.put_random()

    assert conn.assigns.condition == 5
  end
end
