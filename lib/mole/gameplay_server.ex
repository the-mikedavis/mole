defmodule Mole.GameplayServer do
  use GenServer

  alias Mole.Accounts

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

  @play_chunksize Application.get_env(:mole, :play_chunksize)

  # Client API

  @spec get(binary()) :: map() | nil
  def get(username), do: GenServer.call(__MODULE__, {:get, username})

  @spec get_and_del(username) :: map() | nil
  def get_and_del(username),
    do: GenServer.call(__MODULE__, {:get_and_del, username})

  @spec update(binary(), gameplay()) :: :ok
  def update(username, gameplay),
    do: GenServer.cast(__MODULE__, {:update, username, gameplay})

  # Server API

  def start_link(args),
    do: GenServer.start_link(__MODULE__, args, name: __MODULE__)

  @impl GenServer
  def init(_), do: {:ok, %{}}

  @impl GenServer
  def handle_call({:get, username}, _caller, state),
    do: {:reply, Map.get(state, username), state}

  def handle_call({:get_and_del, username}, _caller, state)
    do: {:reply, Map.get(state, username), Map.delete(state, username)}

  def handle_cast({:update, username, gameplay}, state),
    do: {:noreply, Map.put(state, username, gameplay)}
end
