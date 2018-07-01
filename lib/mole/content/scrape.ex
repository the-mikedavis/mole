defmodule Mole.Content.Scrape do
  @moduledoc """
  A Scraper that collects mole images and metadata from the database
  """
  use GenServer
  use Private
  require Logger
  alias Mole.Content.Meta
  alias Mole.Content

  @db_module Mole.Content.Isic
  @std_chunk_size 20
  @min_amount Application.get_env(:mole, :min_amount)
  # 1 seconds
  @time_buffer 1_000
  # 30 seconds
  @await_time 30 * 1_000
  # range of malignant images, in percentage
  @malignant_range Application.get_env(:mole, :malignant_range)

  @auto_start Application.get_env(:mole, :auto_start)

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
  def init(_offset) do
    offset = Content.count_images()

    if @auto_start do
      Logger.info("Starting the scraper")
      Process.send_after(self(), :chunk, @time_buffer)
    end

    {:ok, offset}
  end

  @doc """
  Handle a notification that it's time to collect a chunk.

  If the local datastore should save more images, collect and save a chunk.
  If not, examine the ratio of malignant to non-malignant images in the
  datastore.
  """
  @impl true
  def handle_info(:chunk, offset) do
    total = Content.count_images()

    Logger.info("Received request to get chunk at offset #{offset}")

    if @std_chunk_size + offset <= @min_amount do
      Logger.info("Getting a new chunk, at offset #{offset}")

      download(@std_chunk_size, offset)

      Process.send_after(self(), :chunk, @time_buffer)
    else
      examine_statistics(total)
    end

    {:noreply, offset + @std_chunk_size}
  end

  @doc """
  Onboard a set of images that are only either malignant or benign.
  """
  @impl true
  def handle_cast({:chunk, malignant?, amount}, offset) do
    Logger.info("Got a request to get #{amount} more. Malignant? #{malignant?}")
    download(amount, offset, malignant?: malignant?)

    # check again in a short amount of time
    Process.send_after(self(), :chunk, @time_buffer)

    {:noreply, offset + amount}
  end

  private do
    # Download a chunk from a Source and save it to disk and database
    # If you want malignant ones, use the options keyword list of
    # [malignant?: true], and similar for benign
    @spec download(integer(), integer(), Keyword.t()) :: any()
    def download(amount, offset, options \\ []) do
      amount
      |> @db_module.get_chunk(offset, options)
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
      Logger.debug(fn ->
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
      Logger.debug(fn ->
        """
        Error occurred saving... Reason: #{inspect(reason)}"
        """
      end)

      :ok
    end

    # Insert a Meta struct into the Image Ecto database
    @spec insert(Meta.t()) ::
            {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
    def insert(%Meta{id: id, malignant?: mal}) do
      %{origin_id: id, malignant: mal, path: static_path(id)}
      |> Content.create_image()
    end

    # Produce a static path in which to save the image
    @spec static_path(String.t()) :: String.t()
    def static_path(id), do: "./priv/static/images/#{id}.jpeg"

    import Ecto.Query

    # Ecto query to select malignant images
    @malignant_query from(
                       i in "images",
                       where: [malignant: "TRUE"],
                       select: i.id
                     )

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
      Logger.info("That's #{round(percent / 100 * amount)} images.")

      enforce_ratio(percent, amount)

      :ok
    end

    @spec enforce_ratio(integer(), integer()) :: :ok
    def enforce_ratio(percent, _total) when percent in @malignant_range do
      Logger.info("Percent was in range, done...")

      :ok
    end

    def enforce_ratio(percent, total) do
      mid = midpoint(@malignant_range)
      number_mal = round(percent / 100 * total)

      Process.send_after(
        self(),
        {:"$gen_cast",
         {:chunk, get_malignant?(number_mal, total, mid),
          amount_out(number_mal, total, mid)}},
        @time_buffer
      )

      :ok
    end

    # 100 because the midpoint is a percentage not a ratio
    defguard above_midpoint(count, total, midpoint)
             when round(count / total * 100) > midpoint

    defp get_malignant?(count, total, midpoint)
         when above_midpoint(count, total, midpoint),
         do: false

    defp get_malignant?(_, _, _), do: true

    # x = (100c - mt) / m
    # add benigns
    defp amount_out(count, total, midpoint)
         when above_midpoint(count, total, midpoint) do
      ((100 * count - midpoint * total) / midpoint)
      |> Float.ceil()
      |> round()
    end

    # x = (mt - 100c) / (100 - m)
    # add malignants
    defp amount_out(count, total, midpoint) do
      ((midpoint * total - 100 * count) / (100 - midpoint))
      |> Float.ceil()
      |> round()
    end

    defp midpoint(a..b), do: round((a + b) / 2)
  end
end
