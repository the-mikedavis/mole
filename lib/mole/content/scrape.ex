defmodule Mole.Content.Scrape do
  @moduledoc """
  A Scraper that collects mole images and metadata from the database
  """
  use GenServer
  use Private
  require Logger
  alias Mole.Content.Meta

  @db_module Mole.Content.Isic
  @std_chunk_size 20
  @max_amount Application.get_env(:mole, :max_amount)
  # 1 seconds
  @time_buffer 1_000
  # 30 seconds
  @await_time 30 * 1_000
  # range of malignant images, in percentage
  @malignant_range 35..40

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

    if @std_chunk_size + offset <= @max_amount do
      Logger.info("Gettting a new chunk, at offset #{offset}")

      download(@std_chunk_size, offset)

      Process.send_after(self(), :chunk, @time_buffer)
    else
      examine_statistics(offset)
    end

    {:noreply, Mole.Content.count_images()}
  end

  @doc """
  Onboard a set of images that are only either malignant or benign.

  The `type` parameter is `true` for getting malignant images, false for
  getting `benign images.
  """
  @impl true
  @spec handle_cast({:chunk, boolean(), integer()}, integer()) :: {:noreply, integer()}
  def handle_cast({:chunk, _type, _amount}, _offset) do
    # TODO

    {:noreply, Mole.Content.count_images()}
  end

  private do
    # Download a chunk from a Source and save it to disk and database
    @spec download(integer(), integer()) :: any()
    def download(amount, offset) do
      amount
      |> @db_module.get_chunk(offset)
      |> save_all()
    end

    # Map a function to each element of a collection in parallel.
    @spec pmap(Enum.t(), function()) :: Enum.t()
    def pmap(enumerable, fun) do
      enumerable
      |> Enum.map(&Task.async(fn -> fun.(&1) end))
      |> Enum.map(&Task.await(&1, @await_time))
    end

    # Save all meta structs in a list to local datastore and database.
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

    # Save a single meta structure to the local datastore and database.
    @spec save(Meta.t()) :: :ok
    def save(%Meta{id: id} = meta) do
      id
      |> static_path()
      |> File.open!([:write])
      |> write(@db_module.download(meta))

      meta
    end

    # Write a raw image binary to a file
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

    # Insert a Meta struct into the Image Ecto database
    @spec insert(Meta.t()) :: {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
    def insert(%Meta{id: id, malignant?: mal}) do
      %{origin_id: id, malignant: mal, path: static_path(id)}
      |> Mole.Content.create_image()
    end

    # Produce a static path in which to save the image
    @spec static_path(String.t()) :: String.t()
    def static_path(id), do: "./priv/static/images/#{id}.jpeg"

    import Ecto.Query

    # Ecto query to select malignant images
    @malignant_query from(i in "images", where: [malignant: "TRUE"], select: i.id)

    # Get the percent of malignant images in the local datastore.
    @spec percent_malignant(integer()) :: float()
    def percent_malignant(total_amount) do
      @malignant_query
      |> Mole.Repo.aggregate(:count, :id)
      |> Kernel./(total_amount)
      |> Kernel.*(100)
      |> round()
    end

    # Determine the percentage of malignant images in the Repo
    @spec examine_statistics(integer()) :: :ok
    def examine_statistics(amount) do
      Logger.info("Done. Examining statistics.")

      percent = percent_malignant(amount)

      Logger.info("There are #{amount} images total")
      Logger.info("#{percent}% of which are malignant.")

      enforce_ratio(percent, amount)

      :ok
    end

    def enforce_ratio(percent, _total) when percent in @malignant_range, do: :ok

    def enforce_ratio(_percent, total) do
      m = midpoint(@malignant_range)

      # TODO: check this math for negative condition
      amount_outstanding = round(m * total / (100 - m))

      type = amount_outstanding < 0

      GenServer.cast(__MODULE__, {:chunk, type, abs(amount_outstanding)})
    end

    defp midpoint(a..b), do: round((a + b) / 2)
  end
end
