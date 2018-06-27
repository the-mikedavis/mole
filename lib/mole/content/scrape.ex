defmodule Mole.Content.Scrape do
  @moduledoc """
  A Scraper that collects mole images and metadata from the database
  """
  use GenServer
  require Logger
  alias Mole.Content.Meta

  @db_module Mole.Content.Isic
  @amount 20
  @max_amount Application.get_env(:mole, :max_amount)
  # 1 seconds
  @time_buffer 1_000
  # 30 seconds
  @await_time 30 * 1_000

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_offset) do
    offset = Mole.Content.count_images()

    Process.send_after(self(), :chunk, @time_buffer)

    {:ok, offset}
  end

  @impl true
  def handle_info(:chunk, offset) do
    Logger.info("Received request to get chunk at offset #{offset}")

    if @amount + offset <= @max_amount do
      Logger.info("Gettting a new chunk, at offset #{offset}")

      download(@amount, offset)

      Process.send_after(self(), :chunk, @time_buffer)
    else
      examine_statistics(offset)
    end

    {:noreply, offset + @amount}
  end

  def examine_statistics(amount) do
    Logger.info("Done. Examining statistics. There are #{amount} total.")
  end

  @doc "Download a chunk from a Source"
  @spec download(integer(), integer()) :: any()
  def download(amount, offset) do
    amount
    |> @db_module.get_chunk(offset)
    |> save_all()
  end

  @doc "Parallelized mapping function"
  @spec pmap(Enum.t(), function()) :: Enum.t()
  def pmap(enumerable, fun) do
    enumerable
    |> Enum.map(&Task.async(fn -> fun.(&1) end))
    |> Enum.map(&Task.await(&1, @await_time))
  end

  @spec save_all({:ok, list(Meta.t())}) :: Enum.t()
  defp save_all({:ok, data}) do
    data
    # execute in parallel
    |> pmap(&save/1)
    # execute in serial
    |> Enum.map(&insert/1)
  end

  @spec save_all({:error, any()}) :: :ok
  defp save_all({:error, reason}) do
    Logger.error(fn ->
      """
      Error occurred saving... Reason: #{inspect(reason)}"
      """
    end)

    :ok
  end

  @spec save(Meta.t()) :: :ok
  defp save(%Meta{id: id} = meta) do
    id
    |> static_path()
    |> File.open!([:write])
    |> write(@db_module.download(meta))

    meta
  end

  defp write(file, {:ok, data}), do: IO.binwrite(file, data)

  defp write(_file, {:error, reason}) do
    Logger.error(fn ->
      """
      Error occurred saving... Reason: #{inspect(reason)}"
      """
    end)

    :ok
  end

  defp insert(%Meta{id: id, malignant?: mal}) do
    %{origin_id: id, malignant: mal, path: static_path(id)}
    |> Mole.Content.create_image()
  end

  @spec static_path(String.t()) :: String.t()
  defp static_path(id), do: "./priv/static/images/#{id}.jpeg"
end
