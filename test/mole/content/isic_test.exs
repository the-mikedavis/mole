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

  test "the filter/2 function just spits errors back out" do
    assert Isic.filter({:error, "reason"}, true) == {:error, "reason"}
  end

  test "download/1 on a valid http response" do
    Mox.expect(HTTPoisonMock, :get, fn _ ->
      {:ok, %HTTPoison.Response{status_code: 200, body: "data"}}
    end)

    [to_get | _others] = @payload

    assert Isic.download(to_get) == {:ok, "data"}
  end

  test "download/1 on an invalid http response" do
    error = {:error, %HTTPoison.Error{id: 0, reason: :timeout}}

    Mox.expect(HTTPoisonMock, :get, fn _ -> error end)

    [to_get | _others] = @payload

    assert Isic.download(to_get) == error
  end

  test "http_client/1 is producing the moxed version in :test" do
    assert Isic.http_client() == HTTPoisonMock
  end

  describe "getting a chunk, all the way through," do
    setup do
      rand_5_json = File.read!("test/support/5-random.json")
      rand_5_http = {:ok, %HTTPoison.Response{body: rand_5_json}}

      rand_5_metas =
        {:ok,
         [
           %Mole.Content.Meta{
             id: "5436e3abbae478396759f0cf",
             malignant?: false
           },
           %Mole.Content.Meta{
             id: "5436e3acbae478396759f0d1",
             malignant?: false
           },
           %Mole.Content.Meta{
             id: "5436e3acbae478396759f0d3",
             malignant?: true
           },
           %Mole.Content.Meta{
             id: "5436e3acbae478396759f0d5",
             malignant?: false
           },
           %Mole.Content.Meta{
             id: "5436e3acbae478396759f0d7",
             malignant?: true
           }
         ]}

      mal_5_metas =
        {:ok,
         [
           %Mole.Content.Meta{
             id: "5436e3acbae478396759f0d3",
             malignant?: true
           },
           %Mole.Content.Meta{
             id: "5436e3acbae478396759f0d7",
             malignant?: true
           }
         ]}

      [
        rand_5_http: rand_5_http,
        rand_5_metas: rand_5_metas,
        mal_5_metas: mal_5_metas
      ]
    end

    test "of size 5", c do
      Mox.expect(HTTPoisonMock, :get, fn url ->
        assert url ==
                 "https://isic-archive.com/api/v1/image?limit=5&offset=0&sort=_id&sortdir=1&detail=true"

        c.rand_5_http
      end)

      assert Isic.get_chunk(5, 0) == c.rand_5_metas
    end

    test "of size 5, malignant", c do
      Mox.expect(HTTPoisonMock, :get, fn _url -> c.rand_5_http end)

      assert Isic.get_chunk(5, 0, malignant?: true) == c.mal_5_metas
    end

    test "nil JSON returned" do
      Mox.expect(HTTPoisonMock, :get, fn _url -> nil end)

      assert Isic.get_chunk(5, 0) ==
               {:error,
                %FunctionClauseError{
                  args: nil,
                  arity: 1,
                  clauses: nil,
                  function: :decode!,
                  kind: nil,
                  module: Mole.Content.Isic
                }}
    end
  end
end
