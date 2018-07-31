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
end
