defmodule MoleWeb.GameView do
  use MoleWeb, :view

  alias Mole.Content

  def image_path(image), do: Content.static_path(image)

  def setorsets(1), do: "1 set"
  def setorsets(n), do: "#{n} sets"
end
