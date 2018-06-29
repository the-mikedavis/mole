defmodule Mole.Content.Isic do
  @moduledoc """
  The [ISIC database](https://isic-archive.com/api/v1#!/image/image_download).
  """
  alias Mole.Content.{Source, Meta}
  alias HTTPoison.{Response, Error}
  @behaviour Source

  @base_url "https://isic-archive.com/api/v1/image"
  @http_client Application.get_env(:mole, :http_client)

  @impl Source
  def get_chunk(amount, offset, options \\ [])

  def get_chunk(amount, offset, malignant?: malignant?) do
    amount
    |> get_chunk(offset)
    |> filter(malignant?)
  end

  def get_chunk(amount, offset, []) do
    "#{@base_url}?limit=#{amount}&offset=#{offset}&sort=_id&sortdir=1&detail=true"
    |> @http_client.get()
    |> decode()
  end

  @impl Source
  @doc "Download a single image by id"
  def download(%Meta{id: id}) do
    case @http_client.get("#{@base_url}/#{id}/download") do
      {:ok, %Response{body: image_raw}} -> {:ok, image_raw}
      error -> error
    end
  end

  defp filter({:ok, data}, malignant?) do
    {:ok,
     Enum.filter(data, fn %Meta{malignant?: mal} ->
       mal === malignant?
     end)}
  end

  defp filter({:error, _} = status, _), do: status

  @spec decode({:error, HTTPoison.Error.t()}) :: {:error, binary() | atom()}
  defp decode({:error, %Error{reason: reason}}), do: {:error, reason}

  @spec decode({:ok, HTTPoison.Response.t()}) :: {:ok, list(Meta.t())}
  defp decode({:ok, %Response{body: data}}) do
    valids =
      data
      |> Jason.decode!()
      |> Enum.map(&decode/1)
      |> Enum.filter(fn {status, _} -> status !== :error end)
      |> Enum.map(fn {_status, meta} -> meta end)

    {:ok, valids}
  end

  @spec decode(map()) :: {:ok, Meta.t()} | {:error, any()}
  defp decode(metadata) do
    try do
      {:ok, decode!(metadata)}
    rescue
      e -> {:error, e}
    end
  end

  @spec decode!(map()) :: Meta.t()
  defp decode!(%{"_id" => id, "_modelType" => "image"} = metadata) do
    malignant? =
      metadata
      |> get_in(["meta", "clinical", "benign_malignant"])
      |> is_malignant?()

    %Meta{id: id, malignant?: malignant?}
  end

  defp is_malignant?("malignant"), do: true
  defp is_malignant?(_), do: false
end
