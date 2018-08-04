defmodule Mole.GameplayServerTest do
  use ExUnit.Case, async: true
  alias Mole.GameplayServer, as: GS

  setup do
    on_exit(fn -> Agent.update(__MODULE__, fn _ -> %{} end) end)
  end

  # TODO this will involve database operations (at least a user_fixture)
end
