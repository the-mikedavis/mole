defmodule MoleWeb.GameChannel do
  use Phoenix.Channel

  alias Mole.Content.Image
  alias Mole.Content
  alias Mole.Accounts

  @moduledoc """
  Socket channel for games.

  Involves registering for games, sending images, and handling responses about
  those images from clients.
  """

  @doc """
  Join a new game, which involves assigning a user a new image
  """
  def join("game:new", _params, socket) do
    updated_socket =
      socket
      |> assign(:gameplay, %{correct: 0, incorrect: 0})
      |> assign_new_image()

    {:ok, %{path: updated_socket.assigns.image.path}, updated_socket}
  end

  @doc """
  Handle things the user says.

  If they send an answer to whether or not they thing an image is malignant
  or not, send them whether or not they were correct and update their score.
  """
  def handle_in("answer", malignant?, socket) do
    with correct? <- socket.assigns.image.malignant? == malignant?,
         key <- if(correct?, do: :correct, else: :incorrect),
         gameplay <- Map.update(socket.assigns.gameplay, key, 0, &(&1 + 1)),
         socket <- socket |> assign(:gameplay, gameplay) |> assign_new_image(),
         path <- socket.assigns.image.path do
      Accounts.update_gameplay(socket.assigns.current_user, correct?)

      {:reply, {:ok, %{"correct" => correct?, "path" => path}}, socket}
    end
  end

  # put a new random image into the socket
  # and return the path to that image
  defp assign_new_image(socket) do
    %Image{malignant: malignant, path: "./priv/static" <> path} =
      Content.random_image()

    assign(socket, :image, %{malignant?: malignant, path: path})
  end
end
