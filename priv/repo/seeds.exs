alias Mole.{Content, Content.Image, Content.Set, Accounts, Accounts.Admin, Repo}

sets = 1..4

for set <- sets do
  Repo.get_by(Set, id: set) || Repo.insert!(%Set{id: set, number: set})
end

moles = [
  # Test 1
  %{origin_id: "1V5A2360B", type: "benign", malignant: false, set_id: 1},
  %{origin_id: "1V5A2360D2", type: "benign", malignant: false, set_id: 1},
  %{origin_id: "1V5A2360F", type: "benign", malignant: false, set_id: 1},
  %{origin_id: "Melanoma P", type: "asymmetric", malignant: true, set_id: 1},
  # Test 2
  %{origin_id: "1V5A2380A", type: "benign", malignant: false, set_id: 1},
  %{origin_id: "1V5A2383B", type: "benign", malignant: false, set_id: 1},
  %{origin_id: "1V5A2388C", type: "benign", malignant: false, set_id: 1},
  %{origin_id: "Melanoma C", type: "color", malignant: true, set_id: 1},
  # Test 3
  %{origin_id: "1V5A2615A", type: "benign", malignant: false, set_id: 1},
  %{origin_id: "1V5A2616B", type: "benign", malignant: false, set_id: 1},
  %{origin_id: "1V5A2622D", type: "benign", malignant: false, set_id: 1},
  %{origin_id: "Melanoma Db", type: "borders", malignant: true, set_id: 1},
  # Test 4
  %{origin_id: "1V5A2274", type: "benign", malignant: false, set_id: 2},
  %{origin_id: "1V5A2434", type: "benign", malignant: false, set_id: 2},
  %{origin_id: "1V5A2436", type: "benign", malignant: false, set_id: 2},
  %{origin_id: "Melanoma N", type: "size", malignant: true, set_id: 2},
  # Test 5
  %{origin_id: "1V5A2450", type: "benign", malignant: false, set_id: 2},
  %{origin_id: "1V5A25091", type: "benign", malignant: false, set_id: 2},
  %{origin_id: "1V5A23703", type: "benign", malignant: false, set_id: 2},
  %{origin_id: "Melanoma AA", type: "color", malignant: true, set_id: 2},
  # Test 6
  %{origin_id: "1V5A2320A", type: "benign", malignant: false, set_id: 2},
  %{origin_id: "1V5A2340B", type: "benign", malignant: false, set_id: 2},
  %{origin_id: "1V5A24112bb", type: "benign", malignant: false, set_id: 2},
  %{origin_id: "Melanoma Cb", type: "borders", malignant: true, set_id: 2},
  # Test 7
  %{origin_id: "1V5A2304B", type: "benign", malignant: false, set_id: 3},
  %{origin_id: "1V5A2311C", type: "benign", malignant: false, set_id: 3},
  %{origin_id: "1V5A2316D", type: "benign", malignant: false, set_id: 3},
  %{origin_id: "Melanoma B2", type: "size", malignant: true, set_id: 3},
  # Test 8
  %{origin_id: "1V5A2359B", type: "benign", malignant: false, set_id: 3},
  %{origin_id: "1V5A2360C", type: "benign", malignant: false, set_id: 3},
  %{origin_id: "1V5A2365A", type: "benign", malignant: false, set_id: 3},
  %{origin_id: "Melanoma Kb", type: "borders", malignant: true, set_id: 3},
  # Test 9
  %{origin_id: "1V5A2285", type: "benign", malignant: false, set_id: 3},
  %{origin_id: "1V5A2309B", type: "benign", malignant: false, set_id: 3},
  %{origin_id: "1V5A2311", type: "benign", malignant: false, set_id: 3},
  %{origin_id: "Melanoma Sb", type: "asymmetric", malignant: true, set_id: 3},
  # Test 10
  %{origin_id: "1V5A2384E", type: "benign", malignant: false, set_id: 4},
  %{origin_id: "1V5A2446", type: "benign", malignant: false, set_id: 4},
  %{origin_id: "1V5A2509", type: "benign", malignant: false, set_id: 4},
  %{origin_id: "Melanoma Hc", type: "borders", malignant: true, set_id: 4},
  # Test 11
  %{origin_id: "1V5A2309A", type: "benign", malignant: false, set_id: 4},
  %{origin_id: "1V5A2581A", type: "benign", malignant: false, set_id: 4},
  %{origin_id: "1V5A2581B", type: "benign", malignant: false, set_id: 4},
  %{origin_id: "Melanoma Ab", type: "color", malignant: true, set_id: 4},
  # Test 12
  %{origin_id: "1V5A2359A", type: "benign", malignant: false, set_id: 4},
  %{origin_id: "1V5A2441", type: "benign", malignant: false, set_id: 4},
  %{origin_id: "1V5A2462", type: "benign", malignant: false, set_id: 4},
  %{origin_id: "Melanoma FFb", type: "asymmetric", malignant: true, set_id: 4}
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

admins = Application.fetch_env!(:mole, :default_admins)
default_password = Application.fetch_env!(:mole, :default_password)

for admin <- admins do
  Repo.get_by(Admin, username: admin) || Accounts.create_admin(%{username: admin, password: default_password})
end
