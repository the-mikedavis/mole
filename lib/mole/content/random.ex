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
  @spec set(t_pool(), integer() | nil) :: [%Image{}]
  def set({mals, bens}, condition) when condition in 0..1 do
    decided = Enum.take_random(mals, 2) ++ Enum.take_random(bens, 2)

    undecided =
      case :rand.uniform() do
        n when n < 0.5 -> Enum.random(mals)
        _ -> Enum.random(bens)
      end

    Enum.shuffle([undecided | decided])
  end

  def set({mals, bens}, condition) when condition in 2..3 do
    [Enum.random(mals) | Enum.take_random(bens, 4)]
    |> Enum.shuffle()
  end

  def set({mals, bens}, _condition), do: Enum.take_random(mals ++ bens, 5)

  def refresh, do: GenServer.cast(__MODULE__, :refresh)

  ## Server API

  @doc """
  Initialize the GenServer.

  This will need to be called _after_ the scraper is done collecting images.
  """
  @impl true
  def init(_args) do
    Image
    |> Repo.all()
    |> Enum.map(&Map.take(&1, [:origin_id, :malignant]))
    |> Enum.split_with(fn %Image{malignant: mal?} -> mal? end)
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, {[], []}, name: __MODULE__)
    {:ok, opts}
  end

  @impl true
  def handle_call(:pool, _caller, {mals, bens} = state) do
    {:reply, {Enum.take_random(mals, 16), Enum.take_random(bens, 16)}, state}
  end

  def handle_call(:random, _caller, {mals, bens} = state) do
    {:reply, Enum.take_random(mals ++ bens, 5), state}
  end

  # reload the images in the state
  @impl true
  def handle_cast(:refresh, _state), do: {:noreply, init(nil)}
end
