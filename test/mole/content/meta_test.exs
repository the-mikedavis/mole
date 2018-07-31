defmodule Mole.Content.MetaTest do
  use ExUnit.Case, async: true
  alias Mole.Content.Meta

  test "an example of flattening" do
    assert Meta.flatten(%{"a" => %{"b" => "c"}}) == %{"a.b" => "c"}
  end

  test "a more complicated example of flattening" do
    assert Meta.flatten(%{
             "a" => %{"b" => "c", "d" => %{"e" => "f"}}
           }) == %{"a.b" => "c", "a.d.e" => "f"}
  end

  test "creating a simple csv" do
    csv =
      [%{"a" => "b", "d" => "e"}, %{"a" => "c", "d" => "f"}]
      |> Meta.to_csv()
      |> Enum.take(3)

    assert csv == ["a,d\r\n", "b,e\r\n", "c,f\r\n"]
  end

  test "creating a simple csv with commas" do
    csv =
      [%{"a" => "b,g", "d" => "e"}, %{"a" => "c,h", "d" => "f"}]
      |> Meta.to_csv()
      |> Enum.take(3)

    assert csv == ["a,d\r\n", "\"b,g\",e\r\n", "\"c,h\",f\r\n"]
  end

  test "creating a simple csv with missing keys" do
    csv =
      [%{"a" => "b", "d" => "e"}, %{"d" => "f"}]
      |> Meta.to_csv()
      |> Enum.take(3)

    assert csv == ["a,d\r\n", "b,e\r\n", ",f\r\n"]
  end

  test "creating a real CSV with 5 items" do
    csv =
      TestHelper.rand_5_metas()
      |> Enum.map(fn %{data: data} -> data end)
      |> Meta.to_csv()
      |> Enum.take(10)

    assert csv == TestHelper.csv_first_10()
  end
end
