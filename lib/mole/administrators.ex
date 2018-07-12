defmodule Mole.Administrators do
  use Agent

  @moduledoc """
  An in memory, fluctuable repository of usernames with administrator access.
  """

  @starting_administrators Application.get_env(:mole, :default_admins)

  def start_link(_opts) do
    Agent.start_link(
      fn -> MapSet.new(@starting_administrators) end,
      name: __MODULE__
    )
  end

  @doc "Retreive all administrators"
  @spec all() :: [String.t()]
  def all, do: Agent.get(__MODULE__, &Enum.into(&1, []))

  @doc "Is the username in the list of administrators?"
  @spec is?(String.t()) :: boolean()
  def is?(username),
    do: Agent.get(__MODULE__, &MapSet.member?(&1, username))

  @doc "Add a new administrator to the system."
  @spec add(String.t()) :: :ok
  def add(username),
    do: Agent.update(__MODULE__, &MapSet.put(&1, username))

  @doc "Remove an existing administrator from the system."
  @spec remove(String.t()) :: :ok
  def remove(username),
    do: Agent.update(__MODULE__, &MapSet.delete(&1, username))
end
