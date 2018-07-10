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

  @spec get(binary()) :: GenServer.on_start()
  def get(username), do: GenServer.call(__MODULE__, {:get, username})

  @spec update(binary(), gameplay()) :: :ok | :end
  def update(username, %{correct: cor, incorrect: incor} = gameplay)
      when cor + incor == @play_chunksize do
    GenServer.cast(__MODULE__, {:end, username, gameplay})

    :end
  end

  def update(username, gameplay) do
    GenServer.cast(__MODULE__, {:update, username, gameplay})

    :ok
  end

  # Server API

  def start_link(args),
    do: GenServer.start_link(__MODULE__, args, name: __MODULE__)

  @impl GenServer
  def init(_), do: {:ok, %{}}

  @impl GenServer
  def handle_call({:get, username}, _caller, state),
    do: {:ok, Map.get(state, username), state}

  @impl GenServer
  def handle_cast({:end, username, gameplay}, state) do
    Accounts.save_gameplay(username, gameplay)

    {:noreply, Map.delete(state, username)}
  end

  def handle_cast({:update, username, gameplay}, state),
    do: {:noreply, Map.put(state, username, gameplay)}
end
