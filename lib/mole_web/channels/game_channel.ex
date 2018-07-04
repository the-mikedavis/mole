defmodule MoleWeb.GameChannel do
  use Phoenix.Channel

  @moduledoc """
  Socket channel for games.

  Involves registering for games, sending images, and handling responses about
  those images from clients.
  """

  @doc """
  Join a new game, which involves assigning a user a new image
  """
  def join("game:new", _params, socket) do
    {path, updated_socket} = assign_new_image(socket)

    {:ok, %{path: path}, updated_socket}
  end

  @doc """
  Handle things the user says.

  If they send an answer to whether or not they thing an image is malignant
  or not, send them whether or not they were correct and update their score.
  """
  def handle_in("answer", malignant?, socket) do
    correct? = socket.assigns.image.malignant? == malignant?

    # TODO: change the score of the user here based on their answer
    # Also send them a new image

    {:reply, {:ok, %{"correct" => correct?}}, socket}
  end

  # put a new random image into the socket
  # and return the path to that image
  defp assign_new_image(socket) do
    %Mole.Content.Image{malignant: malignant, path: "./priv/static" <> path} =
      Mole.Content.random_image()

    assign(socket, :image, %{malignant?: malignant})

    {path, socket}
  end
end
