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

  @doc "Update the leaderboard, synchronously"
  @spec update() :: :ok
  def update(repo \\ Repo.all(User)),
    do: GenServer.call(__MODULE__, {:update, repo})

  @doc "Say that the leaderboard is ready for update"
  @spec mark() :: :ok
  def mark, do: GenServer.cast(__MODULE__, :mark)


  # Server API

  # every 30 seconds
  @time_buffer 30 * 1_000

  @doc "Start the leaderboard server"
  @spec start_link(any()) :: GenServer.on_start()
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @doc "Initialize the leaderboard"
  @impl true
  def init(_args) do
    Process.send_after(self(), :update, @time_buffer)

    {:ok, %{marked: false, leaderboard: do_update()}}
  end

  @impl true
  def handle_cast(:mark, state), do: {:noreply, Map.put(state, :marked, true)}

  @doc "Handle a call to update the leaderboard index, asynchronosly"
  @impl true
  def handle_info(:update, %{marked: false} = state) do
    Process.send_after(self(), :update, @time_buffer)

    {:noreply, state}
  end

  def handle_info(:update, _state) do
    Process.send_after(self(), :update, @time_buffer)

    {:noreply, %{leaderboard: do_update(), marked: false}}
  end

  @doc """
  Get a block of users from the leaderboard. Offset is measured from top of the
  leaderboard.
  """
  @impl true
  def handle_call({:block, size, offset}, _from, %{leaderboard: ldb} = state) do
    {:reply, Enum.slice(ldb, offset, size), state}
  end

  def handle_call({:pages, size, offset}, _from, %{leaderboard: ldb} = state) do
    {:reply,
     %{
       current: current_page(ldb, size, offset),
       last: last_page(ldb, size, offset)
     }, state}
  end

  # sync update
  def handle_call({:update, repo}, _caller, state),
    do: {:reply, :ok, Map.put(state, :leaderboard, do_update(repo))}

  private do
    defp do_update(repo \\ Repo.all(User)) do
      repo
      |> Enum.map(&Map.from_struct/1)
      |> Enum.sort_by(& &1.score, &>=/2)
      |> Enum.with_index()
    end

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
