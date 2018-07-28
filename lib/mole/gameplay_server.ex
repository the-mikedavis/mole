defmodule Mole.GameplayServer do
  use GenServer

  @type gameplay :: %{correct: integer(), incorrect: integer()}

  @moduledoc """
  A server for holding game information. It holds the gameplay of users of the
  game, which involves the number of correct and incorrect.

  Gameplay 'sessions' should expire and be saved after a half hour or so.
  After a certain number of plays, the gameplay should be saved to the database.

  This will avoid many operations on the database. The number of database
  operations will be divided by the number of plays allowed before saving.
  This will also make the gameplay more extensible to things like surveys and
  anonymous play.

  The state of the machine should be a map of maps.

  ```
  %{
    "the-mikedavis" => %{
      id: 1, (?)
      correct: 0,
      incorrect: 4
    },
    ...
  }
  ```

  And perhaps an `id` of `nil` can be an anonymous user (not saved to the
  database).
  """

  # Client API

  @doc "Get a user's gameplay by username"
  @spec get(binary()) :: map() | nil
  def get(username), do: GenServer.call(__MODULE__, {:get, username})

  @doc "Return a user's gameplay if and only if it's in progress"
  @spec get_in_progress(binary()) :: map() | nil
  def get_in_progress(username) do
    case get(username) do
      # non existant
      nil ->
        nil

      # done
      %{playable: []} ->
        nil

      # in progress
      gameplay ->
        gameplay
    end
  end

  @doc "Return a user's gameplay if and only if it's done"
  @spec get_done(binary()) :: map() | nil
  def get_done(username) do
    case get(username) do
      # non existant
      nil ->
        nil

      # done
      %{playable: []} = gameplay ->
        gameplay

      # in progress
      _gameplay ->
        nil
    end
  end

  @spec update(binary(), gameplay()) :: gameplay()
  def update(username, gameplay),
    do: GenServer.call(__MODULE__, {:update, username, gameplay})

  # Server API

  def start_link(args),
    do: GenServer.start_link(__MODULE__, args, name: __MODULE__)

  @impl GenServer
  def init(_), do: {:ok, %{}}

  @impl GenServer
  def handle_call({:get, username}, _caller, state),
    do: {:reply, Map.get(state, username), state}

  def handle_call({:update, username, gameplay}, _caller, state),
    do: {:reply, gameplay, Map.put(state, username, gameplay)}
end
