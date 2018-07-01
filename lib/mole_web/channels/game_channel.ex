defmodule MoleWeb.GameChannel do
  use Phoenix.Channel

  @moduledoc """
  Socket channel for games.

  Involves registering for games, sending images, and handling responses about
  those images from clients.
  """

  def join("game:new", _params, socket) do
    # TODO, send an image and assign it to the user
    socket = assign(socket, :image_id, Mole.Content.random_image().id)

    {:ok, socket}
  end

  def handle_in("malignant?", %{"body" => answer}, socket) do
    case Mole.Content.malignant?(socket.assigns.image_id) do
      {:ok, malignant?} -> {:ok, malignant? == answer, socket}
      _ -> {:error, %{reason: "Image does not exist"}}
    end
  end
end
