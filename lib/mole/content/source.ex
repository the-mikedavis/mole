defmodule Mole.Content.Source do
  @moduledoc "A source of images."
  alias Mole.Content.Meta

  @callback get_by_type(integer(), :malignant | :benign) :: list(Meta.t())

  @callback get_chunk(integer(), integer()) ::
              {:ok, list(Meta.t())} | {:error, any()}

  @callback download(Meta.t()) :: {:ok, binary()} | {:error, any()}
end
