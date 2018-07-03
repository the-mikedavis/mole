defmodule Mole.ScrapeTest do
  use ExUnit.Case
  # use Mole.DataCase
  alias Mole.Content.Scrape

  @malignant_range 28..32

  describe "Test the private functions scraper" do
    test "produces a proper static path given a String `id`" do
      assert Scrape.static_path("X") == "./priv/static/images/X.jpeg"
    end

    test "midpoint function gets the number in the middle of a range" do
      assert Scrape.midpoint(0..10) === 5
      # rounds up as well
      assert Scrape.midpoint(0..5) === 3
      # does it with a module attribute
      assert Scrape.midpoint(@malignant_range) === 30
    end

    test "the amount_out/3 function computes correctly for above midpoint" do
      assert Scrape.amount_out(40, 100, 30) === 34
      # Check my own math by asserting that adding more benign images will
      # even out the ration of malignant to benign to a specified range
      assert round(40 / 134 * 100) in @malignant_range
    end

    test "the amount_out/3 function computes correctly for below midpoint" do
      assert Scrape.amount_out(21, 100, 30) === 13
      # Check my own math by asserting that adding more malignant images will
      # even out the ration of malignant to benign to a specified range
      assert round((21 + 13) / 113 * 100) in @malignant_range
    end

    test "get_malignant?/3 filters correctly for the midpoint" do
      assert Scrape.get_malignant?(40, 100, 30) === false
      assert Scrape.get_malignant?(21, 100, 30) === true
    end
  end

  describe "All error-based functions return `:ok`" do
    test "the save_all/1 function" do
      assert Scrape.save_all({:error, "reason"}) == :ok
    end

    test "the write/2 function" do
      assert Scrape.write(nil, {:error, "reason"}) == :ok
    end
  end
end