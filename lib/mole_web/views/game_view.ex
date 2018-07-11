defmodule MoleWeb.GameView do
  use MoleWeb, :view

  alias Mole.Content

  def image_path(image), do: Content.static_path(image)
end
