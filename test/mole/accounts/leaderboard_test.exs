defmodule Mole.Accounts.LeaderboardTest do
  use ExUnit.Case

  alias Mole.Accounts.Leaderboard

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
