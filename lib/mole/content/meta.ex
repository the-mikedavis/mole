defmodule Mole.Content.Meta do
  @moduledoc "An abstract structure of the data needed from a `Source`"

  @typedoc """
  A barebones structure that contains only the id and whether or
  not the mole is cancerous or not.
  """
  @type t :: %__MODULE__{id: String.t(), malignant?: boolean()}

  @enforce_keys [:id, :malignant?]

  defstruct @enforce_keys
end
