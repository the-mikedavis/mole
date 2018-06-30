defmodule Mole.Content.IsicTest do
  use ExUnit.Case
  alias Mole.Content.{Isic, Meta}

  @payload [
    %Meta{malignant?: true, id: "a"},
    %Meta{malignant?: true, id: "b"},
    %Meta{malignant?: true, id: "c"},
    %Meta{malignant?: true, id: "d"},
    %Meta{malignant?: true, id: "e"},
    %Meta{malignant?: false, id: "f"},
    %Meta{malignant?: false, id: "g"},
    %Meta{malignant?: false, id: "h"},
    %Meta{malignant?: false, id: "i"}
  ]

  test "the filter/2 function separates list(Meta.t())'s malignants" do
    # malignant? true
    {:ok, filtered} = Isic.filter({:ok, @payload}, true)

    malignant =
      filtered
      |> Enum.map(fn %Meta{malignant?: m} -> m end)
      |> Enum.reduce(&Kernel.and/2)

    assert malignant
  end

  test "the filter/2 function separates list(Meta.t())'s benigns" do
    # malignant? false
    {:ok, filtered} = Isic.filter({:ok, @payload}, false)

    malignant =
      filtered
      |> Enum.map(fn %Meta{malignant?: m} -> m end)
      |> Enum.reduce(&Kernel.or/2)

    assert not malignant
  end
end
