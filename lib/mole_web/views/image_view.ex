defmodule MoleWeb.ImageView do
  use MoleWeb, :view
  alias Mole.Content

  def path(image), do: Content.static_path(image)
end
