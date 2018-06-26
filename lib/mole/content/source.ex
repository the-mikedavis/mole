defmodule Mole.Content.Source do
  @moduledoc "A source of images."
  alias Mole.Content.Meta

  @callback get_chunk(integer(), integer()) :: {:ok, list(Meta.t())} | {:error, String.t()}

  @callback download(Meta.t()) :: {:ok, binary()} | {:error, any()}
end
