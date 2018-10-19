alias Mole.{Content.Image, Repo}

moles = %{
  "5436e3abbae478396759f0cf" => false,
  "5436e3acbae478396759f0d1" => false,
  "5436e3acbae478396759f0d3" => true,
  "5436e3acbae478396759f0d5" => false,
  "5436e3acbae478396759f0d7" => true,
  "5436e3acbae478396759f0d9" => false,
  "5436e3acbae478396759f0db" => false,
  "5436e3acbae478396759f0dd" => false,
  "5436e3acbae478396759f0df" => false,
  "5436e3acbae478396759f0e1" => false,
  "5436e3acbae478396759f0e3" => false,
  "5436e3acbae478396759f0e5" => false,
  "5436e3acbae478396759f0e7" => false,
  "5436e3adbae478396759f0e9" => true,
  "5436e3adbae478396759f0eb" => false,
  "5436e3adbae478396759f0ed" => false,
  "5436e3adbae478396759f0ef" => false,
  "5436e3adbae478396759f0f1" => false,
  "5436e3adbae478396759f0f3" => false,
  "5436e3adbae478396759f0f5" => false,
  "5436e3adbae478396759f0f7" => false,
  "5436e3adbae478396759f0f9" => false,
  "5436e3aebae478396759f0fb" => true,
  "5436e3aebae478396759f0fd" => false,
  "5436e3aebae478396759f0ff" => false,
  "5436e3aebae478396759f101" => false,
  "5436e3aebae478396759f103" => true,
  "5436e3aebae478396759f105" => false,
  "5436e3aebae478396759f107" => false,
  "5436e3aebae478396759f109" => true,
  "5436e3afbae478396759f10b" => true,
  "5436e3afbae478396759f10d" => true,
  "5436e3afbae478396759f10f" => false,
  "5436e3afbae478396759f111" => false,
  "5436e3afbae478396759f113" => false,
  "5436e3afbae478396759f115" => true,
  "5436e3afbae478396759f117" => true,
  "5436e3afbae478396759f119" => false,
  "5436e3b0bae478396759f11b" => false,
  "5436e3b0bae478396759f11d" => false,
  "5436e3b0bae478396759f11f" => true,
  "5436e3b0bae478396759f121" => false,
  "5436e3b0bae478396759f123" => false,
  "5436e3b0bae478396759f125" => true,
  "5436e3b0bae478396759f127" => false,
  "5436e3b0bae478396759f129" => false,
  "5436e3b1bae478396759f12b" => true,
  "5436e3b1bae478396759f12d" => false,
  "5436e3b1bae478396759f12f" => false,
  "5436e3b1bae478396759f131" => true,
  "5436e3b1bae478396759f133" => false,
  "5436e3b1bae478396759f135" => false,
  "5436e3b1bae478396759f137" => false,
  "5436e3b1bae478396759f139" => false,
  "5436e3b2bae478396759f13b" => true,
  "5436e3b2bae478396759f13d" => false
}

for {id, mal?} <- moles do
  Repo.get_by(Image, origin_id: id) || Repo.insert!(%Image{origin_id: id, malignant: mal?})
end
