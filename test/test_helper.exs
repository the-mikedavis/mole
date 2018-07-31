ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Mole.Repo, :manual)

Mox.defmock(HTTPoisonMock, for: HTTPoison.Base)

defmodule TestHelper do
  def rand_5_metas do
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
    ]
  end

  def rand_2_mals do
    Enum.filter(rand_5_metas(), fn %{malignant?: mal} -> mal end)
  end

  def csv_first_10 do
    [
      "_id,_modelType,created,creator._id,creator.name,dataset._accessLevel,dataset._id,dataset.description,dataset.license,dataset.name,dataset.updated,meta.acquisition.image_type,meta.acquisition.pixelsX,meta.acquisition.pixelsY,meta.clinical.age_approx,meta.clinical.anatom_site_general,meta.clinical.benign_malignant,meta.clinical.diagnosis,meta.clinical.diagnosis_confirm_type,meta.clinical.melanocytic,meta.clinical.sex,meta.unstructured.diagnosis,meta.unstructured.id1,meta.unstructured.localization,meta.unstructured.site,name,notes.reviewed.accepted,notes.reviewed.time,notes.reviewed.userId,notes.tags,updated\r\n",
      "5436e3abbae478396759f0cf,image,2014-10-09T19:36:11.989000+00:00,5450e996bae47865794e4d0d,User 6VSN,0,5a2ecc5e1165975c945942a2,\"Moles and melanomas.\\nBiopsy-confirmed melanocytic lesions. Both malignant and benign lesions are included.\",CC-0,UDA-1,2014-11-10T02:39:56.492000+00:00,dermoscopic,1022,767,55,anterior torso,benign,nevus,,true,female,dysplastic nevus,1,Abdomen,bar,ISIC_0000000,true,2014-11-10T02:39:56.492000+00:00,5436c6e7bae4780a676c8f93,ISBI 2016: TrainingISBI 2017: TrainingChallenge 2018: Task 1-2: Training,2015-02-23T02:48:17.495000+00:00\r\n",
      "5436e3acbae478396759f0d1,image,2014-10-09T19:36:12.070000+00:00,5450e996bae47865794e4d0d,User 6VSN,0,5a2ecc5e1165975c945942a2,\"Moles and melanomas.\\nBiopsy-confirmed melanocytic lesions. Both malignant and benign lesions are included.\",CC-0,UDA-1,2014-11-10T02:39:56.492000+00:00,dermoscopic,1022,767,30,anterior torso,benign,nevus,,true,female,dysplastic nevus,2,Abdomen,bar,ISIC_0000001,true,2014-11-10T02:39:56.492000+00:00,5436c6e7bae4780a676c8f93,ISBI 2016: TrainingISBI 2017: TrainingChallenge 2018: Task 1-2: Training,2015-02-23T02:48:27.455000+00:00\r\n",
      "5436e3acbae478396759f0d3,image,2014-10-09T19:36:12.152000+00:00,5450e996bae47865794e4d0d,User 6VSN,0,5a2ecc5e1165975c945942a2,\"Moles and melanomas.\\nBiopsy-confirmed melanocytic lesions. Both malignant and benign lesions are included.\",CC-0,UDA-1,2014-11-10T02:39:56.492000+00:00,dermoscopic,1022,767,60,upper extremity,malignant,melanoma,histopathology,true,female,Melanoma in situ,3,Upper limb,bar,ISIC_0000002,true,2014-11-10T02:39:56.492000+00:00,5436c6e7bae4780a676c8f93,ISBI 2016: TrainingISBI 2017: Training,2015-02-23T02:48:37.249000+00:00\r\n",
      "5436e3acbae478396759f0d5,image,2014-10-09T19:36:12.233000+00:00,5450e996bae47865794e4d0d,User 6VSN,0,5a2ecc5e1165975c945942a2,\"Moles and melanomas.\\nBiopsy-confirmed melanocytic lesions. Both malignant and benign lesions are included.\",CC-0,UDA-1,2014-11-10T02:39:56.492000+00:00,dermoscopic,1022,767,30,upper extremity,benign,nevus,,true,male,dysplstic nevus,4,Upper limb,bar,ISIC_0000003,true,2014-11-10T02:39:56.492000+00:00,5436c6e7bae4780a676c8f93,ISBI 2016: TestISBI 2017: TrainingChallenge 2018: Task 1-2: Training,2015-02-23T02:48:46.021000+00:00\r\n",
      "5436e3acbae478396759f0d7,image,2014-10-09T19:36:12.315000+00:00,5450e996bae47865794e4d0d,User 6VSN,0,5a2ecc5e1165975c945942a2,\"Moles and melanomas.\\nBiopsy-confirmed melanocytic lesions. Both malignant and benign lesions are included.\",CC-0,UDA-1,2014-11-10T02:39:56.492000+00:00,dermoscopic,1022,767,80,posterior torso,malignant,melanoma,histopathology,true,male,Melanoma,5,Back,bar,ISIC_0000004,true,2014-11-10T02:39:56.492000+00:00,5436c6e7bae4780a676c8f93,ISBI 2016: TrainingISBI 2017: TrainingChallenge 2018: Task 1-2: Training,2015-02-23T02:48:57.303000+00:00\r\n"
    ]
  end
end
