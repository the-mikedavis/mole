defmodule Mole.Accounts.Leaderboard do
  use Private

  @moduledoc """
  The leaderboard.

  Handles the operation of holding the leaderboard in memory, which is an
  ordered list of the users, sorted by score.
  """
  use GenServer
  alias Mole.{Accounts.User, Repo}

  # Client API

  @doc "Get the leaderboard by block."
  @spec get_block(integer(), integer()) :: [{integer(), %User{}}]
  def get_block(size, offset),
    do: GenServer.call(__MODULE__, {:block, size, offset})

  @spec pagination(integer(), integer()) :: %{
          last: integer(),
          current: integer()
        }
  def pagination(size, offset),
    do: GenServer.call(__MODULE__, {:pages, size, offset})

  # Server API

  @doc "Start the leaderboard server"
  @spec start_link(any()) :: GenServer.on_start()
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @doc "Initialize the leaderboard"
  @impl true
  def init(args) do
    GenServer.cast(__MODULE__, :update)

    {:ok, args}
  end

  @doc "Handle a call to update the leaderboard index"
  @impl true
  def handle_cast(:update, _leaderboard) do
    leaderboard =
      User
      |> Repo.all()
      |> Enum.map(&Map.from_struct/1)
      |> Enum.sort_by(& &1.score, &>=/2)
      |> Enum.with_index()

    {:noreply, leaderboard}
  end

  @doc """
  Get a block of users from the leaderboard. Offset is measured from top of the
  leaderboard.
  """
  @impl true
  def handle_call({:block, size, offset}, _caller, leaderboard) do
    {:reply, Enum.slice(leaderboard, offset, size), leaderboard}
  end

  def handle_call({:pages, size, offset}, _caller, leaderboard) do
    {:reply,
     %{
       current: current_page(leaderboard, size, offset),
       last: last_page(leaderboard, size, offset)
     }, leaderboard}
  end

  private do
    defp current_page(_, _, 0), do: 1

    defp current_page(_leaderboard, size, offset) do
      offset
      |> Kernel./(size)
      |> Float.ceil()
      |> round()
    end

    defp last_page([], _, _), do: 1

    defp last_page(leaderboard, size, _offset) do
      leaderboard
      |> length
      |> Kernel./(size)
      |> Float.ceil()
      |> round()
    end
  end
end
