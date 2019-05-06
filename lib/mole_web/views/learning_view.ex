defmodule MoleWeb.LearningView do
  use MoleWeb, :view

  def css_overrides(conn) do
    """
    body {
      background-image: url(#{conn.assigns.image});
    }
    """
  end
end
