defmodule Mole.GameplayServer do
  use Agent

  alias Mole.{Accounts, Content.Random}

  @moduledoc """
  A server for holding game information. It holds the gameplay of users of the
  game, which involves the number of correct and incorrect.
  """

  @type gameplay :: %{correct: integer(), incorrect: integer()}

  @type set :: [%{}]

  # Client API

  def new_set(username) do
    case get(username) do
      nil ->
        user = Accounts.get_user_by_uname(username)
        condition = user.condition
        pool = Random.pool()
        set = Random.set(pool, condition)
        sets_left = 20

        put(username, {sets_left, condition, pool})

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
    case get(username) do
      {1, _condition, _pool} ->
        {status, _} = Accounts.save_gameplay(username, gameplay)

        delete(username)

        status

      {sets_left, condition, pool} ->
        {status, _} = Accounts.save_gameplay(username, gameplay)

        put(username, {sets_left - 1, condition, pool})

        status

      _ ->
        :error
    end
  end

  @doc "get the remaining set count for a user"
  @spec sets_left(String.t()) :: integer()
  def sets_left(username) do
    case get(username) do
      {sets_left, _condition, _pool} -> sets_left
      _ -> nil
    end
  end

  # Server API
  def start_link(_), do: Agent.start_link(fn -> %{} end, name: __MODULE__)

  def get(username), do: Agent.get(__MODULE__, &Map.get(&1, username))

  def put(username, gameplay),
    do: Agent.update(__MODULE__, &Map.put(&1, username, gameplay))

  def delete(username), do: Agent.update(__MODULE__, &Map.delete(&1, username))
end
