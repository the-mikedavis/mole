defmodule Mole.Content.Condition do
  @moduledoc "Helper functions for conditions."

  require Integer

  @eds [:abcde, :duckling, :none]
  @feedback [true, false]
  # the cartesian product of the above
  @conditions for ed <- @eds, fb <- @feedback, do: {ed, fb}
  # number of the above, just cached as a module attribute
  @no_conditions length(@conditions)

  @typedoc "A type of education. Always an atom"
  @type ed :: :abcde | :duckling | :none

  @typedoc "Feedback? `true` or `false`"
  @type feedback :: boolean()

  @doc "Return a random condition integer"
  @spec random() :: integer()
  def random, do: Enum.random(0..(@no_conditions - 1))

  @doc "Return a tuple with the type of education and the feedback predicate."
  @spec to_tuple(integer()) :: {ed(), feedback()}
  def to_tuple(index), do: Enum.at(@conditions, index)

  @doc "Determine if a condition has feedback or not"
  @spec feedback?(integer()) :: boolean()
  def feedback?(condition), do: Integer.is_even(condition)
end
