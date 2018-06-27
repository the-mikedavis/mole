defmodule Mole.Content.Scrape do
  @moduledoc """
  A Scraper that collects mole images and metadata from the database
  """
  use GenServer
  require Logger

  @db_module Mole.Content.Isic
  @amount 20
  @max_amount Application.get_env(:mole, :max_amount)
  # 50 seconds
  @time_buffer 10 * 1_000

  def get_chunk(amount, offset), do: @db_module.get_chunk(amount, offset)

  @impl true
  def init(_offset) do
    # TODO: check status of db as the seek position, initialize seeking
    offset = Mole.Content.count_images()

    Process.send_after(self(), :chunk, @time_buffer)

    {:ok, offset}
  end

  @impl true
  def handle_info(:chunk, offset) do
    if @amount + offset < @max_amount do
      Logger.info("Gettting a new chunk, at offset #{offset}")

      get_chunk(@amount, offset)

      Process.send_after(self(), :chunk, @time_buffer)
    else
      examine_statistics(offset)
    end

    {:noreply, offset + @amount}
  end

  def examine_statistics(amount) do
    Logger.info("Examining statistics. There are #{amount} total.")
  end
end
