defmodule Mole.GameplayServerTest do
  use ExUnit.Case, async: true
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

  # TODO
end
