defmodule Mole.Content.SurveyServer do
  use GenServer

  alias Mole.Content

  @moduledoc """
  The module in charge of holding condition lists for each survey.
  """

  def start_link(opts),
    do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  @doc """
  Take a random available condition.

  This makes it so that the conditions are taken in even cell size across
  different surveys.
  """
  @spec take_random(String.t()) :: non_neg_integer()
  def take_random(survey_name) do
    GenServer.call(__MODULE__, {:take_random, survey_name})
  end

  def handle_call({:take_random, survey_name}, _from, state) do
    conditions = Map.get(state, survey_name)

    condition = Enum.random(conditions)

    conditions =
      case conditions -- [condition] do
        [] -> 0..5
        list -> list
      end

    {:reply, condition, %{state | survey_name => conditions}}
  end

  @spec init(any()) :: [%{String.t() => [non_neg_integer()]}]
  def init(_args) do
    starting_map =
      Content.list_surveys()
      |> Enum.map(fn %{slug: name} ->
        %{name => 0..5}
      end)

    {:ok, starting_map}
  end
end
