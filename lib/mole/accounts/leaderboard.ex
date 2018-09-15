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
  def init(args) do
    Process.send_after(self(), :update, @time_buffer)

    {:ok, args}
  end

  @doc "Handle a call to update the leaderboard index, asynchronosly"
  @impl true
  def handle_info(:update, _leaderboard) do
    Process.send_after(self(), :update, @time_buffer)

    {:noreply, do_update()}
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

  # sync update
  def handle_call({:update, repo}, _caller, _leaderboard),
    do: {:reply, :ok, do_update(repo)}

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
