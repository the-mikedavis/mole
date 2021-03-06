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

  test "a conn without a user has the normal condition" do
    conn =
      build_conn()
      |> init_test_session(%{})
      |> fetch_flash()
      |> Condition.call(%{})

    assert conn.assigns.condition == nil
  end

  test "a conn with a user with no condition has a condition" do
    {:ok, user} = Mole.Accounts.create_user()

    conn =
      build_conn()
      |> init_test_session(%{})
      |> fetch_flash()
      |> assign(:current_user, user)
      |> put_session(:condition, 1)
      |> Condition.call(%{})

    user.id
    |> Mole.Accounts.get_user!()
    |> Mole.Repo.delete!()

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
end
