defmodule Mole.Content.Condition do
  import Kernel, except: [to_string: 1]
  @moduledoc "Helper functions for conditions."

  require Integer

  defp normal, do: 4

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
  @spec to_tuple(nil | integer()) :: {ed(), feedback()}
  def to_tuple(nil), do: to_tuple(normal())
  def to_tuple(index), do: Enum.at(@conditions, index)

  @doc "Determine if a condition has feedback or not"
  @spec feedback?(nil | integer()) :: boolean()
  def feedback?(nil), do: true
  def feedback?(condition), do: Integer.is_even(condition)

  @doc "Give a user friendly string for the doctors."
  @spec to_string(nil | integer() | tuple()) :: String.t()
  def to_string(condition) when is_integer(condition),
    do: condition |> to_tuple() |> to_string()

  def to_string({ed, fb}), do: "learning: #{ed}, feedback?: #{fb}"

  def to_string(nil), do: "N/A"
end
