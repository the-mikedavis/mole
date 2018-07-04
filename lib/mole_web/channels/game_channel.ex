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
    %{
      id: id,
      path: "./priv/static" <> path,
      malignant: malignant?
    } = Mole.Content.random_image()

    socket = assign(socket, :image, %{id: id, malignant?: malignant?})

    {:ok, %{path: path}, socket}
  end

  @doc """
  Handle things the user says.

  If they send an answer to whether or not they thing an image is malignant
  or not, send them whether or not they were correct and update their score.
  """
  def handle_in("answer", malignant?, socket) do
    correct? = socket.assigns.image.malignant? == malignant?

    # TODO: change the score of the user here based on their answer

    {:reply, {:ok, %{"correct" => correct?}}, socket}
  end
end
