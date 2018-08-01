defmodule Mole.Content.ConditionTest do
  use ExUnit.Case, async: true

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

  test "condition strings", c do
    assert Condition.to_string(List.first(c.conditions)) == "learning: abcde, feedback?: true"
  end
end
