defmodule Mole.Content.Random do
  use GenServer

  alias Mole.{Repo, Content.Image}

  @moduledoc """
  The random server, which gives random images.
  """

  @type t_pool :: {[%{}], [%{}]}

  ## Client API

  @doc "Give a pool of images with correct distributions"
  @spec pool() :: t_pool()
  def pool, do: GenServer.call(__MODULE__, :pool)

  @doc "Give a set of images based on the pool and the condition"
  @spec set(t_pool(), integer() | nil) :: {[%Image{}], t_pool()}
  def set(
        {[mal1, mal2, mal3 | mals], [ben1, ben2, ben3, ben4, ben5 | bens]},
        _condition
      ) do
    {Enum.shuffle([mal1, mal2, mal3, ben1, ben2, ben3, ben4, ben5]),
     {mals, bens}}
  end

  def set({mals, bens}, _condition) do
    raise "tried to take a set of #{mals} and #{bens} and failed..."
  end

  # # abcde
  # def set({mals, bens}, condition) when condition in 0..1 do
  # decided = Enum.take_random(mals, 2) ++ Enum.take_random(bens, 2)
  # 
  # undecided =
  # case :rand.uniform() do
  # n when n < 0.5 -> Enum.random(mals)
  # _ -> Enum.random(bens)
  # end
  # 
  # Enum.shuffle([undecided | decided])
  # end
  # 
  # def set({mals, bens}, condition) when condition in 2..3 do
  # [Enum.random(mals) | Enum.take_random(bens, 4)]
  # |> Enum.shuffle()
  # end
  # 
  # def set({mals, bens}, _condition), do: Enum.take_random(mals ++ bens, 5)

  ## Server API

  @doc """
  Initialize the GenServer.

  This will need to be called _after_ the scraper is done collecting images.
  """
  @impl true
  def init(_args), do: {:ok, starting_data()}

  def start_link(_opts),
    do: GenServer.start_link(__MODULE__, {[], []}, name: __MODULE__)

  @impl true
  def handle_call(:pool, _caller, {mals, bens} = state) do
    {:reply, {Enum.shuffle(mals), Enum.shuffle(bens)}, state}
  end

  defp starting_data do
    Image
    |> Repo.all()
    |> Enum.map(&Map.take(&1, [:origin_id, :malignant]))
    |> Enum.split_with(fn %{malignant: mal?} -> mal? end)
  end
end
