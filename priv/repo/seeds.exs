alias Mole.{Content, Content.Image, Content.Set, Repo}

sets = 1..4

for set <- sets do
  Repo.get_by(Set, id: set) || Repo.insert!(%Set{id: set, number: set})
end

moles = [
  %{origin_id: "2c9a31ea-f7b2-4989-b8b6-5e91b451e77a", type: "asymmetric", malignant: true, set_id: 1},
  %{origin_id: "31253b3c-4ede-4d10-9cae-ba015ced97e4", type: "asymmetric", malignant: true, set_id: 2},
  %{origin_id: "ab232200-fd32-481c-bda8-3cd1faed4fb0", type: "asymmetric", malignant: true, set_id: 3},
  %{origin_id: "c4f90448-db5f-4216-801b-57c864be3d3e", type: "asymmetric", malignant: true, set_id: 4},
  %{origin_id: "dbaf3f2a-8537-4755-b567-46eb574a1d21", type: "asymmetric", malignant: true, set_id: 1},
  %{origin_id: "e01b7d1f-3768-40e8-9349-2b215e87a0f2", type: "asymmetric", malignant: true, set_id: 2},
  %{origin_id: "04235851-d853-4117-8eb1-0309270d1467", type: "benign", malignant: false, set_id: 3},
  %{origin_id: "04f34b7a-2723-4eab-aad7-27911474bf98", type: "benign", malignant: false, set_id: 4},
  %{origin_id: "241477b1-0625-423a-9a5f-2b00231b03ff", type: "benign", malignant: false, set_id: 1},
  %{origin_id: "2b1fd10a-41c0-4ff0-8424-45a0eadf0374", type: "benign", malignant: false, set_id: 2},
  %{origin_id: "3e7586b3-5e3a-4769-b687-a4b07ba809f5", type: "benign", malignant: false, set_id: 3},
  %{origin_id: "4a7158dc-aed2-4a16-98e4-adbac7759113", type: "benign", malignant: false, set_id: 4},
  %{origin_id: "566569c6-cd53-4859-a3ca-eef331d24b3a", type: "benign", malignant: false, set_id: 1},
  %{origin_id: "58cfc004-81cc-4793-9e7f-03987b084013", type: "benign", malignant: false, set_id: 2},
  %{origin_id: "60d668ab-a676-4835-ab98-69d4dcc5ad86", type: "benign", malignant: false, set_id: 3},
  %{origin_id: "78a7d014-d372-4a4f-8b64-ed98ebe1e944", type: "benign", malignant: false, set_id: 4},
  %{origin_id: "842d9f13-7797-4d63-bf93-70da64af5c11", type: "benign", malignant: false, set_id: 1},
  %{origin_id: "85973d97-2ace-465e-8239-5deda0ccddee", type: "benign", malignant: false, set_id: 2},
  %{origin_id: "94144bd9-2088-498a-b5fc-5297aef869e9", type: "benign", malignant: false, set_id: 3},
  %{origin_id: "c8d38be1-0d9a-49fb-82a7-f30d8cf7d035", type: "benign", malignant: false, set_id: 4},
  %{origin_id: "cf228dca-ff44-4903-892d-36489c7c6c64", type: "benign", malignant: false, set_id: 1},
  %{origin_id: "d79c7da9-9932-4f49-b317-d56a9cadc497", type: "benign", malignant: false, set_id: 2},
  %{origin_id: "da96197a-3224-4d43-a86a-16c93321dd89", type: "benign", malignant: false, set_id: 3},
  %{origin_id: "ef0f7ee1-b569-43a4-bcd6-e5d15aad35d4", type: "benign", malignant: false, set_id: 4},
  %{origin_id: "ef620646-fa5f-4e2b-9cea-09fb732968ba", type: "benign", malignant: false, set_id: 1},
  %{origin_id: "fd065e15-d8d8-4e8d-b86d-045ced3e3d61", type: "benign", malignant: false, set_id: 2},
  %{origin_id: "5436e3c9bae478396759f275", type: "benign", malignant: false, set_id: 3},
  %{origin_id: "5436e3c9bae478396759f277", type: "benign", malignant: false, set_id: 4},
  %{origin_id: "5436e3cabae478396759f27b", type: "benign", malignant: false, set_id: 1},
  %{origin_id: "5436e3cabae478396759f27f", type: "benign", malignant: false, set_id: 2},
  %{origin_id: "3a536810-8dbb-4c2f-acf0-eaabe4fed701", type: "border", malignant: false, set_id: 3},
  %{origin_id: "4c351671-9172-4040-a822-8cab8e58fc58", type: "border", malignant: false, set_id: 4},
  %{origin_id: "63fa52e0-b80e-4152-95ae-ba1bbf40ed0c", type: "border", malignant: false, set_id: 1},
  %{origin_id: "7cd228cc-57bb-4622-b5b6-8e4b294b3d7a", type: "border", malignant: false, set_id: 2},
  %{origin_id: "edd5dc4c-81c7-4994-935a-65a69fe62356", type: "border", malignant: false, set_id: 3},
  %{origin_id: "f74f1fd8-0f7f-4f5d-8e83-dbc59c9c4292", type: "border", malignant: false, set_id: 4},
  %{origin_id: "6801b846-9abc-4408-9a39-fe10c9b2b63b", type: "color", malignant: true, set_id: 1},
  %{origin_id: "681b0820-7d59-4323-883c-0371a3e64e4e", type: "color", malignant: true, set_id: 2},
  %{origin_id: "6a2557fb-415c-4614-9771-8ce769a9dcd7", type: "color", malignant: true, set_id: 3},
  %{origin_id: "aba8c149-6c0d-48f7-a338-c7ba9fade447", type: "color", malignant: true, set_id: 4},
  %{origin_id: "b99a293f-6da7-49f2-984b-8d1da94641b5", type: "color", malignant: true, set_id: 1},
  %{origin_id: "c99b662a-80b2-4ec6-925a-2d8e78a5e341", type: "color", malignant: true, set_id: 2},
  %{origin_id: "0deade9f-0710-4d33-a8e5-c4524d7da166", type: "diameter", malignant: true, set_id: 3},
  %{origin_id: "3197d28e-80c4-42fb-a629-3e813e86d715", type: "diameter", malignant: true, set_id: 4},
  %{origin_id: "4d12bf78-bb03-44f6-8482-33bdc3f1c9c5", type: "diameter", malignant: true, set_id: 1},
  %{origin_id: "4d73a348-fa7e-44d3-a8b2-66818f7f4772", type: "diameter", malignant: true, set_id: 2},
  %{origin_id: "6aa7f29e-f99a-4de6-9beb-582846882c5a", type: "diameter", malignant: true, set_id: 3},
  %{origin_id: "d6d80829-679e-4b25-9f51-ea90fedbf0f1", type: "diameter", malignant: true, set_id: 4}
]

for image <- moles do
  with %Image{} = i <- Repo.get_by(Image, origin_id: image.origin_id) do
    if i.set_id == image.set_id do
      :ok
    else
      i
      |> Image.changeset(%{set_id: image.set_id})
      |> Repo.update()
    end
  else
    nil -> Content.create_image(image)
  end
end
