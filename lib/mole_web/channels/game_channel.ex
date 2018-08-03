defmodule MoleWeb.GameChannel do
  use Phoenix.Channel

  alias Mole.{Content, Content.Condition, GameplayServer}
  alias MoleWeb.Endpoint
  alias MoleWeb.Router.Helpers, as: Routes

  @type gameplay :: %{
          playable: [%{}],
          played: [%{}],
          correct: integer(),
          incorrect: integer()
        }

  @moduledoc """
  Socket channel for games.

  Involves registering for games, sending images, and handling responses about
  those images from clients.
  """

  @doc """
  Join a new game, which involves assigning a socket a new set and giving
  the first image.
  """
  def join("game:new", _params, socket) do
    {condition, set} = GameplayServer.new_set(socket.assigns.username)

    socket =
      socket
      |> assign(:condition, condition)
      |> assign(:gameplay, gameplay(set))

    {:ok, %{paths: all_image_paths(socket)}, socket}
  end

  @doc """
  Handle things the user says.

  Figure out if they're correct or not and mark that in the gameplay.
  Update the gameplay for the next image.
  """
  def handle_in("answer", malignant?, socket) do
    with correct? <- current_image(socket).malignant == malignant?,
         socket <- update_gameplay(socket, correct?) do
      case socket.assigns.gameplay.playable do
        [] ->
          recap_path = Routes.game_path(Endpoint, :show)

          {:reply, {:ok, %{"reroute" => true, "path" => recap_path}}, socket}

        _list ->
          reply =
            if(Condition.feedback?(socket.assigns.condition),
              do: %{"correct" => correct?},
              else: %{}
            )
            |> Map.put("path", current_image_path(socket))

          {:reply, {:ok, reply}, socket}
      end
    end
  end

  @spec gameplay(GameplayServer.set()) :: gameplay()
  defp gameplay(set), do: %{playable: set, correct: 0, incorrect: 0}

  defp current_image(%{assigns: %{gameplay: %{playable: []}}}),
    do: raise("GameChannel tried to get the next image after all ran out!")

  defp current_image(%{assigns: %{gameplay: %{playable: [h | _t]}}}), do: h

  defp current_image_path(socket) do
    socket
    |> current_image()
    |> Content.static_path()
  end

  defp all_image_paths(socket) do
    socket.assigns.gameplay.playable
    |> Enum.shuffle()
    |> Enum.map(&Content.static_path/1)
  end

  # remove the head of the gameplay list, update correct/incorrect
  defp update_gameplay(%{assigns: %{gameplay: gameplay}} = socket, correct?) do
    correctness = if correct?, do: :correct, else: :incorrect
    [_just_played | to_play] = gameplay.playable

    new_gameplay =
      gameplay
      |> Map.put(:playable, to_play)
      |> Map.update!(correctness, &(&1 + 1))

    assign(socket, :gameplay, new_gameplay)
  end
end
