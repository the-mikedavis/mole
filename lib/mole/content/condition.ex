defmodule Mole.Content.Condition do
  use Private
  import Kernel, except: [to_string: 1]
  @moduledoc "Helper functions for conditions."

  require Integer

  # no learning, standard feedback
  defp normal, do: 7

  @eds [:abcd, :duckling, :none, :both]
  @feedback [:motivational, :standard, :none]
  # the cartesian product of the above
  @conditions for ed <- @eds, fb <- @feedback, do: {ed, fb}
  # number of the above, just cached as a module attribute
  @no_conditions length(@conditions)

  @typedoc "A type of education. Always an atom"
  @type ed :: :abcd | :duckling | :none

  @typedoc "Feedback? Always an atom"
  @type feedback :: :motivational | :standard | :none

  @doc "Return a random condition integer"
  @spec random() :: integer()
  def random, do: Enum.random(0..(@no_conditions - 1))

  @doc "Return a tuple with the type of education and feedback."
  @spec to_tuple(nil | integer()) :: {ed(), feedback()}
  def to_tuple(nil), do: to_tuple(normal())
  def to_tuple(index), do: Enum.at(@conditions, index)

  @doc "Determine if a condition has feedback or not"
  @spec feedback(nil | integer()) :: feedback()
  def feedback(nil), do: :standard
  def feedback(condition) when condition in [0, 3, 6, 9], do: :motivational
  def feedback(condition) when condition in [1, 4, 7, 10], do: :standard
  def feedback(condition) when condition in [2, 5, 8, 11], do: :none

  @spec learning(nil | integer()) :: ed()
  def learning(nil), do: :none
  def learning(condition) when condition in 0..2, do: :abcd
  def learning(condition) when condition in 3..5, do: :duckling
  def learning(condition) when condition in 6..8, do: :none
  def learning(condition) when condition in 9..11, do: :both

  @doc "Give a user friendly string for the doctors."
  @spec to_string(nil | integer() | tuple()) :: String.t()
  def to_string(condition) when is_integer(condition),
    do: condition |> to_tuple() |> to_string()

  def to_string({ed, fb}), do: "learning: #{ed}, feedback: #{fb}"

  def to_string(nil), do: "N/A"

  @doc "Return the learning image for the condition at the page number"
  @spec image_for(integer(), String.t()) :: String.t()
  def image_for(condition, page) when is_integer(condition) do
    {ed, _feedback} = to_tuple(condition)

    learning = "#{ed}_#{page}.png"

    case Enum.filter(images_available(), fn image -> image =~ learning end) do
      [match] -> match
      _ -> nil
    end
  end

  @spec images_available() :: [String.t()]
  defp images_available do
    ["#{:code.priv_dir(:mole)}", "static", "images", "*.png"]
    |> Path.join()
    |> Path.wildcard()
    |> Enum.map(fn abs_name ->
      "/#{abs_name |> Path.split() |> Enum.take(-2) |> Path.join()}"
    end)
  end
end
