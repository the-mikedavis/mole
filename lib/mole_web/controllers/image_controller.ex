defmodule MoleWeb.ImageController do
  use MoleWeb, :controller
  alias Mole.{Content, Content.Image, Repo}

  def index(conn, _params) do
    images = Repo.all(Image)

    render(conn, "index.html", images: images)
  end

  def show(conn, %{"id" => id}) do
    image = Content.get_image!(id)

    render(conn, "show.html", image: image)
  end
end
