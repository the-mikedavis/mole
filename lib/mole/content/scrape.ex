defmodule Mole.Content.Scrape do
  @moduledoc """
  A Scraper that collects mole images and metadata from the database
  """
  use GenServer
  use Private
  require Logger
  alias Mole.Content.Meta

  @db_module Mole.Content.Isic
  @amount 20
  @max_amount Application.get_env(:mole, :max_amount)
  # 1 seconds
  @time_buffer 1_000
  # 30 seconds
  @await_time 30 * 1_000

  @doc "Start the scraper as a worker"
  @spec start_link(any()) :: GenServer.on_start()
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @doc """
  Initialize the scraper.

  Get the number of images in the database. Save that as the state of the
  server. Send a notification that a chunk is ready to be collected.
  """
  @impl true
  @spec init(any()) :: {:ok, integer()}
  def init(_offset) do
    offset = Mole.Content.count_images()

    Process.send_after(self(), :chunk, @time_buffer)

    {:ok, offset}
  end

  @doc """
  Handle a notification that it's time to collect a chunk.

  If the local datastore should save more images, collect and save a chunk.
  If not, examine the ratio of malignant to non-malignant images in the
  datastore.
  """
  @impl true
  @spec handle_info(:chunk, integer()) :: {:noreply, integer()}
  def handle_info(:chunk, offset) do
    Logger.info("Received request to get chunk at offset #{offset}")

    if @amount + offset <= @max_amount do
      Logger.info("Gettting a new chunk, at offset #{offset}")

      download(@amount, offset)

      Process.send_after(self(), :chunk, @time_buffer)
    else
      examine_statistics(offset)
    end

    {:noreply, Mole.Content.count_images()}
  end

  private do
    @doc "Download a chunk from a Source and save it to disk and database"
    @spec download(integer(), integer()) :: any()
    def download(amount, offset) do
      amount
      |> @db_module.get_chunk(offset)
      |> save_all()
    end

    @doc "Map a function to each element of a collection in parallel."
    @spec pmap(Enum.t(), function()) :: Enum.t()
    def pmap(enumerable, fun) do
      enumerable
      |> Enum.map(&Task.async(fn -> fun.(&1) end))
      |> Enum.map(&Task.await(&1, @await_time))
    end

    @doc "Save all meta structs in a list to local datastore and database."
    @spec save_all({:ok, list(Meta.t())}) :: Enum.t()
    def save_all({:ok, data}) do
      data
      # execute in parallel
      |> pmap(&save/1)
      # execute in serial
      |> Enum.map(&insert/1)
    end

    @spec save_all({:error, any()}) :: :ok
    def save_all({:error, reason}) do
      Logger.error(fn ->
        """
        Error occurred saving... Reason: #{inspect(reason)}"
        """
      end)

      :ok
    end

    @doc "Save a single meta structure to the local datastore and database."
    @spec save(Meta.t()) :: :ok
    def save(%Meta{id: id} = meta) do
      id
      |> static_path()
      |> File.open!([:write])
      |> write(@db_module.download(meta))

      meta
    end

    @doc "Write a raw image binary to a file"
    @spec write(File.t(), {:ok, binary()}) :: :ok | {:error, term()}
    def write(file, {:ok, data}), do: IO.binwrite(file, data)

    @spec write(File.t(), {:error, any()}) :: :ok
    def write(_file, {:error, reason}) do
      Logger.error(fn ->
        """
        Error occurred saving... Reason: #{inspect(reason)}"
        """
      end)

      :ok
    end

    @doc "Insert a Meta struct into the Image Ecto database"
    @spec insert(Meta.t()) :: {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
    def insert(%Meta{id: id, malignant?: mal}) do
      %{origin_id: id, malignant: mal, path: static_path(id)}
      |> Mole.Content.create_image()
    end

    @doc "Produce a static path in which to save the image"
    @spec static_path(String.t()) :: String.t()
    def static_path(id), do: "./priv/static/images/#{id}.jpeg"

    import Ecto.Query

    # 30%
    # @ratio_malignant_percent 0.3

    # Ecto query to select malignant images
    @malignant_query from(i in "images", where: [malignant: "TRUE"], select: i.id)

    @doc "Get the ratio of malignant images in the local datastore."
    @spec ratio_malignant(integer()) :: float()
    def ratio_malignant(total_amount) do
      Mole.Repo.aggregate(@malignant_query, :count, :id) / total_amount
    end

    @doc "Determine the percentage of malignant images in the Repo."
    @spec examine_statistics(integer()) :: :ok
    def examine_statistics(amount) do
      Logger.info("Done. Examining statistics.")

      percent = ratio_malignant(amount)

      Logger.info("There are #{amount} images total")
      Logger.info("#{round(percent * 100)}% of which are malignant.")

      :ok
    end
  end
end
