defmodule Mole.GameplayServer do
  use Agent

  # alias Mole.{Accounts, Content, Content.Random}
  alias Mole.{Accounts, Content}

  @moduledoc """
  A server for holding game information. It holds the gameplay of users of the
  game, which involves the number of correct and incorrect.
  """

  # the id is the user_id
  @typep id :: integer()

  @type gameplay :: %{correct: integer(), incorrect: integer()}

  @type set :: [%{}]

  @sets 4

  # Client API

  @spec new_set(id()) :: {integer(), [map()]}
  def new_set(id) do
    set_number =
      id
      |> get()
      |> case do
        nil ->
          put(id, @sets)

          1

        sets_left ->
          5 - sets_left
      end

    set =
      set_number
      |> Content.get_images_by_set()
      |> Enum.map(&Map.take(&1, [:origin_id, :id, :malignant]))
      |> Enum.shuffle()

    {set_number, set}
  end

  @doc """
  Save a set of play (to the database for that user)

  If that user has played through all of their sets, they're done and can
  be deleted from the server.
  """
  @spec save_set(id(), map()) :: :ok | :error
  def save_set(id, gameplay) do
    case get(id) do
      1 ->
        delete(id)

      sets_left ->
        put(id, sets_left - 1)
    end

    {status, _} = Accounts.save_gameplay(id, gameplay)

    status
  end

  @doc "get the remaining set count for a user"
  @spec sets_left(id()) :: integer()
  def sets_left(id), do: get(id) || 0

  @doc "get the current set number for a user"
  @spec set_number(id()) :: integer()
  def set_number(id), do: @sets - sets_left(id)

  # Server API
  def start_link(_), do: Agent.start_link(fn -> %{} end, name: __MODULE__)

  def get(id), do: Agent.get(__MODULE__, &Map.get(&1, id))

  def put(id, gameplay),
    do: Agent.update(__MODULE__, &Map.put(&1, id, gameplay))

  def delete(id), do: Agent.update(__MODULE__, &Map.delete(&1, id))
end
