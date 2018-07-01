defmodule Mole.Content.Leaderboard do
  use GenServer
  alias Mole.Accounts.User
  alias Mole.Repo

  @doc "Start the leaderboard server"
  @spec start_link(any()) :: GenServer.on_start()
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @doc "Initialize the leaderboard"
  @impl true
  def init(_args) do
    GenServer.cast(__MODULE__, :index)

    {:ok, []}
  end

  @doc "Handle a call to update the leaderboard index"
  @impl true
  def handle_cast(:update, _leaderboard) do
    leaderboard =
      User
      |> Repo.all()
      |> Enum.sort_by(&(&1.score), &>=/2)
      |> Enum.with_index()

    {:ok, leaderboard}
  end

  @doc """
  Get a block of users from the leaderboard. Offset is measured from top of the
  leaderboard.
  """
  @impl true
  def handle_call({:block, size, offset}, _caller, leaderboard) do
    {:ok, Enum.slice(leaderboard, offset, size)}
  end
end
