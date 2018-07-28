defmodule Mole.GameplayServerTest do
  use ExUnit.Case
  alias Mole.GameplayServer, as: GS

  setup do
    # start_supervised!(GS)

    on_exit(fn -> GS.update("username", nil) end)

    [
      in_progress: %{playable: [3, 4], played: [1, 2]},
      done: %{playable: [], played: [1, 2, 3, 4]},
      uname: "username"
    ]
  end

  test "getting a username", c do
    assert GS.get(c.uname) == nil

    assert GS.update(c.uname, c.in_progress) == c.in_progress

    assert GS.get(c.uname) == c.in_progress
  end

  test "getting a username in progress", c do
    assert GS.get(c.uname) == nil

    assert GS.update(c.uname, c.in_progress) == c.in_progress

    assert GS.get_in_progress(c.uname) == c.in_progress
  end

  test "getting a username done", c do
    assert GS.get(c.uname) == nil

    assert GS.update(c.uname, c.done) == c.done

    assert GS.get_done(c.uname) == c.done
  end
end
