defmodule Mole.Accounts.LeaderboardTest do
  use Mole.DataCase, async: true

  alias Mole.{Accounts, Accounts.Leaderboard}

  describe "the main functionality" do
    @user_valid_attrs %{username: "someusername", password: "some password"}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@user_valid_attrs)
        |> Accounts.create_user()

      user
    end
  end

  describe "the leaderboard" do
    test "getting a block with multiple users" do
      user1 = user_fixture(%{score: 20})
      user2 = user_fixture(%{username: "anotherusername", score: 40})

      Leaderboard.update()

      [{gotten1, _rank1}, {gotten2, _rank2}] = Leaderboard.get_block(20, 0)

      assert gotten1.id == user2.id
      assert gotten2.id == user1.id
    end

    test "pagination with multiple users" do
      user_fixture(%{score: 20})
      user_fixture(%{username: "anotherusername", score: 40})

      Leaderboard.update()

      assert Leaderboard.pagination(20, 0) == %{current: 1, last: 1}
    end
  end

  describe "the private functions" do
    test "getting the current page" do
      assert Leaderboard.current_page(Enum.to_list(1..98), 20, 60) == 3
      assert Leaderboard.current_page(Enum.to_list(1..101), 20, 60) == 3
      assert Leaderboard.current_page([], 20, 0) == 1
      assert Leaderboard.current_page([1], 20, 0) == 1
    end

    test "getting the last page" do
      assert Leaderboard.last_page(Enum.to_list(1..98), 20, 60) == 5
      assert Leaderboard.last_page(Enum.to_list(1..101), 20, 60) == 6
      assert Leaderboard.last_page([], 20, 0) == 1
    end
  end
end
