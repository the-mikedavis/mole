defmodule Mole.GameplayServer do
  use GenServer

  alias Mole.{Accounts, Content.Random}

  @type gameplay :: %{correct: integer(), incorrect: integer()}

  @type set :: [%{}]

  @moduledoc """
  A server for holding game information. It holds the gameplay of users of the
  game, which involves the number of correct and incorrect.

  ```
  %{
    "the-mikedavis" => %{
  .... gameplay ....
    },
    ...
  }
  ```
  """

  # Client API

  def new_set(username) do
    case GenServer.call(__MODULE__, {:get, username}) do
      nil ->
        user = Accounts.get_user_by_uname(username)
        condition = user.condition
        pool = Random.pool()
        set = Random.set(pool, condition)
        sets_left = 20

        GenServer.call(
          __MODULE__,
          {:put, username, {sets_left, condition, pool}}
        )

        {condition, set}

      {_sets_left, condition, pool} ->
        set = Random.set(pool, condition)

        {condition, set}
    end
  end

  @doc """
  Save a set of play (to the database for that user)

  If that user has played through all of their sets, they're done and can
  be deleted from the server.
  """
  @spec save_set(String.t(), %{}) :: :ok | :error
  def save_set(username, gameplay) do
    case GenServer.call(__MODULE__, {:get, username}) do
      {1, _condition, _pool} ->
        {status, _} = Accounts.save_gameplay(username, gameplay)
        GenServer.call(__MODULE__, {:delete, username})

        status

      {sets_left, condition, pool} ->
        {status, _} = Accounts.save_gameplay(username, gameplay)

        GenServer.call(
          __MODULE__,
          {:put, username, {sets_left - 1, condition, pool}}
        )

        status

      _ ->
        :error
    end
  end

  @doc "get the remaining set count for a user"
  @spec sets_left(String.t()) :: integer()
  def sets_left(username) do
    case GenServer.call(__MODULE__, {:get, username}) do
      {sets_left, _condition, _pool} -> sets_left
      _ -> nil
    end
  end

  # Server API
  # TODO yeah only really need an Agent

  def start_link(args),
    do: GenServer.start_link(__MODULE__, args, name: __MODULE__)

  @impl GenServer
  def init(_), do: {:ok, %{}}

  @impl GenServer
  def handle_call({:get, username}, _caller, state),
    do: {:reply, Map.get(state, username), state}

  def handle_call({:put, username, attrs}, _caller, state),
    do: {:reply, attrs, Map.put(state, username, attrs)}

  def handle_call({:delete, username}, _caller, state),
    do: {:reply, username, Map.delete(state, username)}
end
