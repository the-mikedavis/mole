defmodule MoleWeb.GameChannel do
  use Phoenix.Channel

  alias Mole.GameplayServer
  alias Mole.Content.Image
  alias Mole.Content

  @moduledoc """
  Socket channel for games.

  Involves registering for games, sending images, and handling responses about
  those images from clients.
  """

  @play_chunksize Application.get_env(:mole, :play_chunksize)

  @doc """
  Join a new game, which involves assigning a user a new image
  """
  def join("game:new", _params, socket) do
    socket =
      case GameplayServer.get(socket.assigns.username) do
        nil -> assign_new_gameplay(socket)
        gameplay -> assign(socket, :gameplay, gameplay)
      end

    {:ok, %{path: current_image(socket)}, socket}
  end

  @doc """
  Handle things the user says.

  When the user has played for the proper chunk size, they'll be finished with
  one set and will be re-routed to the results page.
  """
  def handle_in("answer", malignant?, socket) do
    with correct? <- current_image(socket).malignant? == malignant?,
         socket <- update_gameplay(socket, correct?),
         path <- current_image(socket).path do
      case GameplayServer.update(socket.assigns.username, socket.gameplay) do
        :ok ->
          {:reply, {:ok, %{"reroute" => false, "path" => path}}, socket}

        :end ->
          {:reply, {:ok, %{"reroute" => true}}, socket}
      end
    end
  end

  defp assign_new_gameplay(socket) do
    images =
      @play_chunksize
      |> Content.random_images()
      |> Enum.map(fn %Image{malignant: malignant?, path: path} ->
        %{malignant?: malignant?, path: path}
      end)

    socket
    |> assign(:gameplay, %{correct: 0, incorrect: 0})
    |> put_in([:assigns, :gameplay, :images], images)
  end

  defp current_image(%{assigns: %{gameplay: %{images: [h | _t]}}}), do: h

  defp update_gameplay(socket, correct?) do
    key = if correct?, do: :correct, else: :incorrect

    socket
    |> update_in([:assigns, :gameplay, key], &(&1 + 1))
    |> update_in([:assigns, :gameplay, :images], &tail/1)
  end

  defp tail([]), do: nil
  defp tail([_h | tail]), do: tail
end
