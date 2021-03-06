defmodule Mole.Content.Random do
  use GenServer

  alias Mole.{Repo, Content.Image}

  @moduledoc """
  The random server, which gives random images.
  """

  @type t_pool :: {[%{}], [%{}]}

  # half of the total set size will be taken from the pool of malignants and
  # benigns
  @half_size 6

  ## Client API

  @doc "Give a pool of images with correct distributions"
  @spec pool() :: t_pool()
  def pool, do: GenServer.call(__MODULE__, :pool)

  @doc "Give a set of images based on the pool and the condition"
  @spec set(t_pool(), integer() | nil) :: {[%Image{}], t_pool()}
  def set({mals, bens}, _condition) do
    rand_mals = Enum.take_random(mals, @half_size)
    rand_bens = Enum.take_random(bens, @half_size)

    {
      Enum.shuffle(rand_mals ++ rand_bens),
      {mals -- rand_mals, bens -- rand_bens}
    }
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
    |> Enum.map(&Map.take(&1, [:origin_id, :id, :malignant]))
    |> Enum.split_with(fn %{malignant: mal?} -> mal? end)
  end
end
