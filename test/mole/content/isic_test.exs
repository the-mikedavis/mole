defmodule Mole.Content.IsicTest do
  use ExUnit.Case, async: true
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
             malignant?: false,
             data: %{
               "_id" => "5436e3abbae478396759f0cf",
               "_modelType" => "image",
               "created" => "2014-10-09T19:36:11.989000+00:00",
               "creator" => %{
                 "_id" => "5450e996bae47865794e4d0d",
                 "name" => "User 6VSN"
               },
               "dataset" => %{
                 "_accessLevel" => 0,
                 "_id" => "5a2ecc5e1165975c945942a2",
                 "description" =>
                   "Moles and melanomas.\nBiopsy-confirmed melanocytic lesions. Both malignant and benign lesions are included.",
                 "license" => "CC-0",
                 "name" => "UDA-1",
                 "updated" => "2014-11-10T02:39:56.492000+00:00"
               },
               "meta" => %{
                 "acquisition" => %{
                   "image_type" => "dermoscopic",
                   "pixelsX" => 1022,
                   "pixelsY" => 767
                 },
                 "clinical" => %{
                   "age_approx" => 55,
                   "anatom_site_general" => "anterior torso",
                   "benign_malignant" => "benign",
                   "diagnosis" => "nevus",
                   "diagnosis_confirm_type" => nil,
                   "melanocytic" => true,
                   "sex" => "female"
                 },
                 "unstructured" => %{
                   "diagnosis" => "dysplastic nevus",
                   "id1" => "1",
                   "localization" => "Abdomen",
                   "site" => "bar"
                 },
                 "unstructuredExif" => %{}
               },
               "name" => "ISIC_0000000",
               "notes" => %{
                 "reviewed" => %{
                   "accepted" => true,
                   "time" => "2014-11-10T02:39:56.492000+00:00",
                   "userId" => "5436c6e7bae4780a676c8f93"
                 },
                 "tags" => [
                   "ISBI 2016: Training",
                   "ISBI 2017: Training",
                   "Challenge 2018: Task 1-2: Training"
                 ]
               },
               "updated" => "2015-02-23T02:48:17.495000+00:00"
             }
           },
           %Mole.Content.Meta{
             id: "5436e3acbae478396759f0d1",
             malignant?: false,
             data: %{
               "_id" => "5436e3acbae478396759f0d1",
               "_modelType" => "image",
               "created" => "2014-10-09T19:36:12.070000+00:00",
               "creator" => %{
                 "_id" => "5450e996bae47865794e4d0d",
                 "name" => "User 6VSN"
               },
               "dataset" => %{
                 "_accessLevel" => 0,
                 "_id" => "5a2ecc5e1165975c945942a2",
                 "description" =>
                   "Moles and melanomas.\nBiopsy-confirmed melanocytic lesions. Both malignant and benign lesions are included.",
                 "license" => "CC-0",
                 "name" => "UDA-1",
                 "updated" => "2014-11-10T02:39:56.492000+00:00"
               },
               "meta" => %{
                 "acquisition" => %{
                   "image_type" => "dermoscopic",
                   "pixelsX" => 1022,
                   "pixelsY" => 767
                 },
                 "clinical" => %{
                   "age_approx" => 30,
                   "anatom_site_general" => "anterior torso",
                   "benign_malignant" => "benign",
                   "diagnosis" => "nevus",
                   "diagnosis_confirm_type" => nil,
                   "melanocytic" => true,
                   "sex" => "female"
                 },
                 "unstructured" => %{
                   "diagnosis" => "dysplastic nevus",
                   "id1" => "2",
                   "localization" => "Abdomen",
                   "site" => "bar"
                 },
                 "unstructuredExif" => %{}
               },
               "name" => "ISIC_0000001",
               "notes" => %{
                 "reviewed" => %{
                   "accepted" => true,
                   "time" => "2014-11-10T02:39:56.492000+00:00",
                   "userId" => "5436c6e7bae4780a676c8f93"
                 },
                 "tags" => [
                   "ISBI 2016: Training",
                   "ISBI 2017: Training",
                   "Challenge 2018: Task 1-2: Training"
                 ]
               },
               "updated" => "2015-02-23T02:48:27.455000+00:00"
             }
           },
           %Mole.Content.Meta{
             id: "5436e3acbae478396759f0d3",
             malignant?: true,
             data: %{
               "_id" => "5436e3acbae478396759f0d3",
               "_modelType" => "image",
               "created" => "2014-10-09T19:36:12.152000+00:00",
               "creator" => %{
                 "_id" => "5450e996bae47865794e4d0d",
                 "name" => "User 6VSN"
               },
               "dataset" => %{
                 "_accessLevel" => 0,
                 "_id" => "5a2ecc5e1165975c945942a2",
                 "description" =>
                   "Moles and melanomas.\nBiopsy-confirmed melanocytic lesions. Both malignant and benign lesions are included.",
                 "license" => "CC-0",
                 "name" => "UDA-1",
                 "updated" => "2014-11-10T02:39:56.492000+00:00"
               },
               "meta" => %{
                 "acquisition" => %{
                   "image_type" => "dermoscopic",
                   "pixelsX" => 1022,
                   "pixelsY" => 767
                 },
                 "clinical" => %{
                   "age_approx" => 60,
                   "anatom_site_general" => "upper extremity",
                   "benign_malignant" => "malignant",
                   "diagnosis" => "melanoma",
                   "diagnosis_confirm_type" => "histopathology",
                   "melanocytic" => true,
                   "sex" => "female"
                 },
                 "unstructured" => %{
                   "diagnosis" => "Melanoma in situ",
                   "id1" => "3",
                   "localization" => "Upper limb",
                   "site" => "bar"
                 },
                 "unstructuredExif" => %{}
               },
               "name" => "ISIC_0000002",
               "notes" => %{
                 "reviewed" => %{
                   "accepted" => true,
                   "time" => "2014-11-10T02:39:56.492000+00:00",
                   "userId" => "5436c6e7bae4780a676c8f93"
                 },
                 "tags" => ["ISBI 2016: Training", "ISBI 2017: Training"]
               },
               "updated" => "2015-02-23T02:48:37.249000+00:00"
             }
           },
           %Mole.Content.Meta{
             id: "5436e3acbae478396759f0d5",
             malignant?: false,
             data: %{
               "_id" => "5436e3acbae478396759f0d5",
               "_modelType" => "image",
               "created" => "2014-10-09T19:36:12.233000+00:00",
               "creator" => %{
                 "_id" => "5450e996bae47865794e4d0d",
                 "name" => "User 6VSN"
               },
               "dataset" => %{
                 "_accessLevel" => 0,
                 "_id" => "5a2ecc5e1165975c945942a2",
                 "description" =>
                   "Moles and melanomas.\nBiopsy-confirmed melanocytic lesions. Both malignant and benign lesions are included.",
                 "license" => "CC-0",
                 "name" => "UDA-1",
                 "updated" => "2014-11-10T02:39:56.492000+00:00"
               },
               "meta" => %{
                 "acquisition" => %{
                   "image_type" => "dermoscopic",
                   "pixelsX" => 1022,
                   "pixelsY" => 767
                 },
                 "clinical" => %{
                   "age_approx" => 30,
                   "anatom_site_general" => "upper extremity",
                   "benign_malignant" => "benign",
                   "diagnosis" => "nevus",
                   "diagnosis_confirm_type" => nil,
                   "melanocytic" => true,
                   "sex" => "male"
                 },
                 "unstructured" => %{
                   "diagnosis" => "dysplstic nevus",
                   "id1" => "4",
                   "localization" => "Upper limb",
                   "site" => "bar"
                 },
                 "unstructuredExif" => %{}
               },
               "name" => "ISIC_0000003",
               "notes" => %{
                 "reviewed" => %{
                   "accepted" => true,
                   "time" => "2014-11-10T02:39:56.492000+00:00",
                   "userId" => "5436c6e7bae4780a676c8f93"
                 },
                 "tags" => [
                   "ISBI 2016: Test",
                   "ISBI 2017: Training",
                   "Challenge 2018: Task 1-2: Training"
                 ]
               },
               "updated" => "2015-02-23T02:48:46.021000+00:00"
             }
           },
           %Mole.Content.Meta{
             id: "5436e3acbae478396759f0d7",
             malignant?: true,
             data: %{
               "_id" => "5436e3acbae478396759f0d7",
               "_modelType" => "image",
               "created" => "2014-10-09T19:36:12.315000+00:00",
               "creator" => %{
                 "_id" => "5450e996bae47865794e4d0d",
                 "name" => "User 6VSN"
               },
               "dataset" => %{
                 "_accessLevel" => 0,
                 "_id" => "5a2ecc5e1165975c945942a2",
                 "description" =>
                   "Moles and melanomas.\nBiopsy-confirmed melanocytic lesions. Both malignant and benign lesions are included.",
                 "license" => "CC-0",
                 "name" => "UDA-1",
                 "updated" => "2014-11-10T02:39:56.492000+00:00"
               },
               "meta" => %{
                 "acquisition" => %{
                   "image_type" => "dermoscopic",
                   "pixelsX" => 1022,
                   "pixelsY" => 767
                 },
                 "clinical" => %{
                   "age_approx" => 80,
                   "anatom_site_general" => "posterior torso",
                   "benign_malignant" => "malignant",
                   "diagnosis" => "melanoma",
                   "diagnosis_confirm_type" => "histopathology",
                   "melanocytic" => true,
                   "sex" => "male"
                 },
                 "unstructured" => %{
                   "diagnosis" => "Melanoma",
                   "id1" => "5",
                   "localization" => "Back",
                   "site" => "bar"
                 },
                 "unstructuredExif" => %{}
               },
               "name" => "ISIC_0000004",
               "notes" => %{
                 "reviewed" => %{
                   "accepted" => true,
                   "time" => "2014-11-10T02:39:56.492000+00:00",
                   "userId" => "5436c6e7bae4780a676c8f93"
                 },
                 "tags" => [
                   "ISBI 2016: Training",
                   "ISBI 2017: Training",
                   "Challenge 2018: Task 1-2: Training"
                 ]
               },
               "updated" => "2015-02-23T02:48:57.303000+00:00"
             }
           }
         ]}

      {:ok,
       [
         %Mole.Content.Meta{
           id: "5436e3abbae478396759f0cf",
           malignant?: false,
           data: %{
             "_id" => "5436e3abbae478396759f0cf",
             "_modelType" => "image",
             "created" => "2014-10-09T19:36:11.989000+00:00",
             "creator" => %{
               "_id" => "5450e996bae47865794e4d0d",
               "name" => "User 6VSN"
             },
             "dataset" => %{
               "_accessLevel" => 0,
               "_id" => "5a2ecc5e1165975c945942a2",
               "description" =>
                 "Moles and melanomas.\nBiopsy-confirmed melanocytic lesions. Both malignant and benign lesions are included.",
               "license" => "CC-0",
               "name" => "UDA-1",
               "updated" => "2014-11-10T02:39:56.492000+00:00"
             },
             "meta" => %{
               "acquisition" => %{
                 "image_type" => "dermoscopic",
                 "pixelsX" => 1022,
                 "pixelsY" => 767
               },
               "clinical" => %{
                 "age_approx" => 55,
                 "anatom_site_general" => "anterior torso",
                 "benign_malignant" => "benign",
                 "diagnosis" => "nevus",
                 "diagnosis_confirm_type" => nil,
                 "melanocytic" => true,
                 "sex" => "female"
               },
               "unstructured" => %{
                 "diagnosis" => "dysplastic nevus",
                 "id1" => "1",
                 "localization" => "Abdomen",
                 "site" => "bar"
               },
               "unstructuredExif" => %{}
             },
             "name" => "ISIC_0000000",
             "notes" => %{
               "reviewed" => %{
                 "accepted" => true,
                 "time" => "2014-11-10T02:39:56.492000+00:00",
                 "userId" => "5436c6e7bae4780a676c8f93"
               },
               "tags" => [
                 "ISBI 2016: Training",
                 "ISBI 2017: Training",
                 "Challenge 2018: Task 1-2: Training"
               ]
             },
             "updated" => "2015-02-23T02:48:17.495000+00:00"
           }
         },
         %Mole.Content.Meta{
           id: "5436e3acbae478396759f0d1",
           malignant?: false,
           data: %{
             "_id" => "5436e3acbae478396759f0d1",
             "_modelType" => "image",
             "created" => "2014-10-09T19:36:12.070000+00:00",
             "creator" => %{
               "_id" => "5450e996bae47865794e4d0d",
               "name" => "User 6VSN"
             },
             "dataset" => %{
               "_accessLevel" => 0,
               "_id" => "5a2ecc5e1165975c945942a2",
               "description" =>
                 "Moles and melanomas.\nBiopsy-confirmed melanocytic lesions. Both malignant and benign lesions are included.",
               "license" => "CC-0",
               "name" => "UDA-1",
               "updated" => "2014-11-10T02:39:56.492000+00:00"
             },
             "meta" => %{
               "acquisition" => %{
                 "image_type" => "dermoscopic",
                 "pixelsX" => 1022,
                 "pixelsY" => 767
               },
               "clinical" => %{
                 "age_approx" => 30,
                 "anatom_site_general" => "anterior torso",
                 "benign_malignant" => "benign",
                 "diagnosis" => "nevus",
                 "diagnosis_confirm_type" => nil,
                 "melanocytic" => true,
                 "sex" => "female"
               },
               "unstructured" => %{
                 "diagnosis" => "dysplastic nevus",
                 "id1" => "2",
                 "localization" => "Abdomen",
                 "site" => "bar"
               },
               "unstructuredExif" => %{}
             },
             "name" => "ISIC_0000001",
             "notes" => %{
               "reviewed" => %{
                 "accepted" => true,
                 "time" => "2014-11-10T02:39:56.492000+00:00",
                 "userId" => "5436c6e7bae4780a676c8f93"
               },
               "tags" => [
                 "ISBI 2016: Training",
                 "ISBI 2017: Training",
                 "Challenge 2018: Task 1-2: Training"
               ]
             },
             "updated" => "2015-02-23T02:48:27.455000+00:00"
           }
         },
         %Mole.Content.Meta{
           id: "5436e3acbae478396759f0d3",
           malignant?: true,
           data: %{
             "_id" => "5436e3acbae478396759f0d3",
             "_modelType" => "image",
             "created" => "2014-10-09T19:36:12.152000+00:00",
             "creator" => %{
               "_id" => "5450e996bae47865794e4d0d",
               "name" => "User 6VSN"
             },
             "dataset" => %{
               "_accessLevel" => 0,
               "_id" => "5a2ecc5e1165975c945942a2",
               "description" =>
                 "Moles and melanomas.\nBiopsy-confirmed melanocytic lesions. Both malignant and benign lesions are included.",
               "license" => "CC-0",
               "name" => "UDA-1",
               "updated" => "2014-11-10T02:39:56.492000+00:00"
             },
             "meta" => %{
               "acquisition" => %{
                 "image_type" => "dermoscopic",
                 "pixelsX" => 1022,
                 "pixelsY" => 767
               },
               "clinical" => %{
                 "age_approx" => 60,
                 "anatom_site_general" => "upper extremity",
                 "benign_malignant" => "malignant",
                 "diagnosis" => "melanoma",
                 "diagnosis_confirm_type" => "histopathology",
                 "melanocytic" => true,
                 "sex" => "female"
               },
               "unstructured" => %{
                 "diagnosis" => "Melanoma in situ",
                 "id1" => "3",
                 "localization" => "Upper limb",
                 "site" => "bar"
               },
               "unstructuredExif" => %{}
             },
             "name" => "ISIC_0000002",
             "notes" => %{
               "reviewed" => %{
                 "accepted" => true,
                 "time" => "2014-11-10T02:39:56.492000+00:00",
                 "userId" => "5436c6e7bae4780a676c8f93"
               },
               "tags" => ["ISBI 2016: Training", "ISBI 2017: Training"]
             },
             "updated" => "2015-02-23T02:48:37.249000+00:00"
           }
         },
         %Mole.Content.Meta{
           id: "5436e3acbae478396759f0d5",
           malignant?: false,
           data: %{
             "_id" => "5436e3acbae478396759f0d5",
             "_modelType" => "image",
             "created" => "2014-10-09T19:36:12.233000+00:00",
             "creator" => %{
               "_id" => "5450e996bae47865794e4d0d",
               "name" => "User 6VSN"
             },
             "dataset" => %{
               "_accessLevel" => 0,
               "_id" => "5a2ecc5e1165975c945942a2",
               "description" =>
                 "Moles and melanomas.\nBiopsy-confirmed melanocytic lesions. Both malignant and benign lesions are included.",
               "license" => "CC-0",
               "name" => "UDA-1",
               "updated" => "2014-11-10T02:39:56.492000+00:00"
             },
             "meta" => %{
               "acquisition" => %{
                 "image_type" => "dermoscopic",
                 "pixelsX" => 1022,
                 "pixelsY" => 767
               },
               "clinical" => %{
                 "age_approx" => 30,
                 "anatom_site_general" => "upper extremity",
                 "benign_malignant" => "benign",
                 "diagnosis" => "nevus",
                 "diagnosis_confirm_type" => nil,
                 "melanocytic" => true,
                 "sex" => "male"
               },
               "unstructured" => %{
                 "diagnosis" => "dysplstic nevus",
                 "id1" => "4",
                 "localization" => "Upper limb",
                 "site" => "bar"
               },
               "unstructuredExif" => %{}
             },
             "name" => "ISIC_0000003",
             "notes" => %{
               "reviewed" => %{
                 "accepted" => true,
                 "time" => "2014-11-10T02:39:56.492000+00:00",
                 "userId" => "5436c6e7bae4780a676c8f93"
               },
               "tags" => [
                 "ISBI 2016: Test",
                 "ISBI 2017: Training",
                 "Challenge 2018: Task 1-2: Training"
               ]
             },
             "updated" => "2015-02-23T02:48:46.021000+00:00"
           }
         },
         %Mole.Content.Meta{
           id: "5436e3acbae478396759f0d7",
           malignant?: true,
           data: %{
             "_id" => "5436e3acbae478396759f0d7",
             "_modelType" => "image",
             "created" => "2014-10-09T19:36:12.315000+00:00",
             "creator" => %{
               "_id" => "5450e996bae47865794e4d0d",
               "name" => "User 6VSN"
             },
             "dataset" => %{
               "_accessLevel" => 0,
               "_id" => "5a2ecc5e1165975c945942a2",
               "description" =>
                 "Moles and melanomas.\nBiopsy-confirmed melanocytic lesions. Both malignant and benign lesions are included.",
               "license" => "CC-0",
               "name" => "UDA-1",
               "updated" => "2014-11-10T02:39:56.492000+00:00"
             },
             "meta" => %{
               "acquisition" => %{
                 "image_type" => "dermoscopic",
                 "pixelsX" => 1022,
                 "pixelsY" => 767
               },
               "clinical" => %{
                 "age_approx" => 80,
                 "anatom_site_general" => "posterior torso",
                 "benign_malignant" => "malignant",
                 "diagnosis" => "melanoma",
                 "diagnosis_confirm_type" => "histopathology",
                 "melanocytic" => true,
                 "sex" => "male"
               },
               "unstructured" => %{
                 "diagnosis" => "Melanoma",
                 "id1" => "5",
                 "localization" => "Back",
                 "site" => "bar"
               },
               "unstructuredExif" => %{}
             },
             "name" => "ISIC_0000004",
             "notes" => %{
               "reviewed" => %{
                 "accepted" => true,
                 "time" => "2014-11-10T02:39:56.492000+00:00",
                 "userId" => "5436c6e7bae4780a676c8f93"
               },
               "tags" => [
                 "ISBI 2016: Training",
                 "ISBI 2017: Training",
                 "Challenge 2018: Task 1-2: Training"
               ]
             },
             "updated" => "2015-02-23T02:48:57.303000+00:00"
           }
         }
       ]}

      mal_5_metas =
        {:ok,
         [
           %Mole.Content.Meta{
             id: "5436e3acbae478396759f0d3",
             malignant?: true,
             data: %{
               "_id" => "5436e3acbae478396759f0d3",
               "_modelType" => "image",
               "created" => "2014-10-09T19:36:12.152000+00:00",
               "creator" => %{
                 "_id" => "5450e996bae47865794e4d0d",
                 "name" => "User 6VSN"
               },
               "dataset" => %{
                 "_accessLevel" => 0,
                 "_id" => "5a2ecc5e1165975c945942a2",
                 "description" =>
                   "Moles and melanomas.\nBiopsy-confirmed melanocytic lesions. Both malignant and benign lesions are included.",
                 "license" => "CC-0",
                 "name" => "UDA-1",
                 "updated" => "2014-11-10T02:39:56.492000+00:00"
               },
               "meta" => %{
                 "acquisition" => %{
                   "image_type" => "dermoscopic",
                   "pixelsX" => 1022,
                   "pixelsY" => 767
                 },
                 "clinical" => %{
                   "age_approx" => 60,
                   "anatom_site_general" => "upper extremity",
                   "benign_malignant" => "malignant",
                   "diagnosis" => "melanoma",
                   "diagnosis_confirm_type" => "histopathology",
                   "melanocytic" => true,
                   "sex" => "female"
                 },
                 "unstructured" => %{
                   "diagnosis" => "Melanoma in situ",
                   "id1" => "3",
                   "localization" => "Upper limb",
                   "site" => "bar"
                 },
                 "unstructuredExif" => %{}
               },
               "name" => "ISIC_0000002",
               "notes" => %{
                 "reviewed" => %{
                   "accepted" => true,
                   "time" => "2014-11-10T02:39:56.492000+00:00",
                   "userId" => "5436c6e7bae4780a676c8f93"
                 },
                 "tags" => ["ISBI 2016: Training", "ISBI 2017: Training"]
               },
               "updated" => "2015-02-23T02:48:37.249000+00:00"
             }
           },
           %Mole.Content.Meta{
             id: "5436e3acbae478396759f0d7",
             malignant?: true,
             data: %{
               "_id" => "5436e3acbae478396759f0d7",
               "_modelType" => "image",
               "created" => "2014-10-09T19:36:12.315000+00:00",
               "creator" => %{
                 "_id" => "5450e996bae47865794e4d0d",
                 "name" => "User 6VSN"
               },
               "dataset" => %{
                 "_accessLevel" => 0,
                 "_id" => "5a2ecc5e1165975c945942a2",
                 "description" =>
                   "Moles and melanomas.\nBiopsy-confirmed melanocytic lesions. Both malignant and benign lesions are included.",
                 "license" => "CC-0",
                 "name" => "UDA-1",
                 "updated" => "2014-11-10T02:39:56.492000+00:00"
               },
               "meta" => %{
                 "acquisition" => %{
                   "image_type" => "dermoscopic",
                   "pixelsX" => 1022,
                   "pixelsY" => 767
                 },
                 "clinical" => %{
                   "age_approx" => 80,
                   "anatom_site_general" => "posterior torso",
                   "benign_malignant" => "malignant",
                   "diagnosis" => "melanoma",
                   "diagnosis_confirm_type" => "histopathology",
                   "melanocytic" => true,
                   "sex" => "male"
                 },
                 "unstructured" => %{
                   "diagnosis" => "Melanoma",
                   "id1" => "5",
                   "localization" => "Back",
                   "site" => "bar"
                 },
                 "unstructuredExif" => %{}
               },
               "name" => "ISIC_0000004",
               "notes" => %{
                 "reviewed" => %{
                   "accepted" => true,
                   "time" => "2014-11-10T02:39:56.492000+00:00",
                   "userId" => "5436c6e7bae4780a676c8f93"
                 },
                 "tags" => [
                   "ISBI 2016: Training",
                   "ISBI 2017: Training",
                   "Challenge 2018: Task 1-2: Training"
                 ]
               },
               "updated" => "2015-02-23T02:48:57.303000+00:00"
             }
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
