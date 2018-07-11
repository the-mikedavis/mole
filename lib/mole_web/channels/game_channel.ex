defmodule MoleWeb.GameChannel do
  use Phoenix.Channel

  alias Mole.{Content, GameplayServer}
  alias MoleWeb.{Endpoint, Router.Helpers}

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

    {:ok, %{path: current_image_path(socket)}, socket}
  end

  @doc """
  Handle things the user says.

  When the user has played for the proper chunk size, they'll be finished with
  one set and will be re-routed to the results page.
  """
  def handle_in("answer", malignant?, socket) do
    with correct? <- current_image(socket).malignant? == malignant?,
         socket <- update_gameplay(socket, correct?) do
      GameplayServer.update(socket.assigns.username, socket.assigns.gameplay)

      case socket.assigns.gameplay.playable do
        [] ->
          recap_path = Helpers.game_path(Endpoint, :show)

          {:reply, {:ok, %{"reroute" => true, "path" => recap_path}}, socket}

        _list ->
          {:reply,
           {:ok, %{"reroute" => false, "path" => current_image_path(socket)}},
           socket}
      end
    end
  end

  defp assign_new_gameplay(socket) do
    images =
      @play_chunksize
      |> Content.random_images()
      |> Enum.map(&Map.from_struct/1)
      # TODO: consider removing from schema
      |> Enum.map(&Map.delete(&1, :origin_id))

    assign(socket, :gameplay, %{playable: images, played: []})
  end

  defp current_image(%{assigns: %{gameplay: %{playable: [h | _t]}}}), do: h

  defp current_image_path(socket) do
    socket
    |> current_image()
    |> Content.static_path()
  end

  defp update_gameplay(socket, correct?) do
    with gameplay <- socket.assigns.gameplay,
         [just_played | to_play] <- gameplay.playable,
         just_played <- Map.put(just_played, :correct?, correct?),
         # N.B. the `played` list will need to be reversed at the end
         gameplay <-
           %{playable: to_play, played: [just_played | gameplay.played]},
         do: assign(socket, :gameplay, gameplay)
  end
end
