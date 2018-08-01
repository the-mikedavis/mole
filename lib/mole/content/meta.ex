defmodule Mole.Content.Meta do
  @moduledoc "An abstract structure of the data needed from a `Source`"

  @typedoc """
  A barebones structure that contains only the id and whether or
  not the mole is cancerous or not.
  """
  @type t :: %__MODULE__{
          id: String.t(),
          malignant?: boolean(),
          data: String.t()
        }

  @enforce_keys [:id, :malignant?]

  defstruct [:data | @enforce_keys]

  @doc """
  Flatten the metadata into a single map

  The map comes in nested and leaves as a single level map, appropriate for
  representation as a CSV or spreadsheet.

  Since keys are nested, its necessary to see their origin to understand them.
  The flattening process takes place by joining nested keys together with the
  canonical "." connective.
  """
  @spec flatten(map()) :: map()
  def flatten(map) do
    map
    |> Map.keys()
    |> Enum.reduce(%{}, fn key, acc ->
      if is_map(map[key]) do
        map[key]
        |> flatten()
        |> Enum.reduce(%{}, fn {subkey, subval}, subacc ->
          Map.put(subacc, key <> "." <> subkey, subval)
        end)
        |> Map.merge(acc)
      else
        Map.put(acc, key, map[key])
      end
    end)
  end

  @doc """
  Make the list of metadata maps into a csv.

  Actually expects maps, not Meta.t()'s
  """
  @spec to_csv([%{}]) :: Stream.t()
  def to_csv(metalist) when is_list(metalist) do
    maps = Enum.map(metalist, &flatten/1)

    headers =
      maps
      |> Enum.reduce(&Map.merge/2)
      |> Map.keys()
      |> Enum.sort()

    CSV.encode(maps, headers: headers)
  end
end
