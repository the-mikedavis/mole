defmodule Mole.Content.ConditionTest do
  use ExUnit.Case

  alias Mole.Content.Condition

  setup do
    [
      conditions: [
        abcde: true,
        abcde: false,
        duckling: true,
        duckling: false,
        none: true,
        none: false
      ]
    ]
  end

  test "random condition", c do
    assert Condition.random() in 0..(length(c.conditions) - 1)
  end

  test "condition tuples", c do
    for condition <- 0..5 do
      assert Condition.to_tuple(condition) == Enum.at(c.conditions, condition)
    end
  end
end
