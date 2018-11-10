defmodule MoleWeb.GameChannel do
  use Phoenix.Channel

  alias Mole.{
    Accounts,
    Accounts.User,
    Content,
    Content.Condition,
    GameplayServer
  }

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
    {set_number, set} = GameplayServer.new_set(socket.assigns.username)

    %User{condition: condition} =
      Accounts.get_user_by_uname(socket.assigns.username)

    socket =
      socket
      |> assign(:condition, condition)
      |> assign(:gameplay, gameplay(set))
      |> assign(:set_number, set_number)

    {:ok, %{paths: all_image_paths(socket)}, socket}
  end

  @doc """
  Handle things the user says.

  Figure out if they're correct or not and mark that in the gameplay.
  Update the gameplay for the next image.
  """
  def handle_in("answer", malignant?, socket) do
    malignant = current_image(socket).malignant
    correct? = malignant == malignant?
    socket = update_gameplay(socket, correct?)

    feedback? =
      Condition.feedback?(socket.assigns.condition) &&
        socket.assigns.set_number == 1

    feedback_map = give_feedback(feedback?, correct?, malignant)

    reply =
      case socket.assigns.gameplay.playable do
        [] ->
          GameplayServer.save_set(
            socket.assigns.username,
            socket.assigns.gameplay
          )

          Map.merge(feedback_map, %{
            "reroute" => true,
            "path" => recap_path(socket)
          })

        _list ->
          Map.put(feedback_map, "path", current_image_path(socket))
      end

    {:reply, {:ok, reply}, socket}
  end

  @spec gameplay(GameplayServer.set()) :: gameplay()
  defp gameplay(set), do: %{playable: set, correct: 0, incorrect: 0, bonus: 0}

  defp current_image(%{assigns: %{gameplay: %{playable: []}}}),
    do: raise("GameChannel tried to get the next image after all ran out!")

  defp current_image(%{assigns: %{gameplay: %{playable: [h | _t]}}}), do: h

  defp current_image_path(socket) do
    socket
    |> current_image()
    |> Content.static_path()
  end

  defp all_image_paths(socket) do
    Enum.map(socket.assigns.gameplay.playable, &Content.static_path/1)
  end

  # remove the head of the gameplay list, update correct/incorrect
  defp update_gameplay(%{assigns: %{gameplay: gameplay}} = socket, correct?) do
    correctness = if correct?, do: :correct, else: :incorrect
    [just_played | to_play] = gameplay.playable

    just_played = Map.put(just_played, :correct, correct?)

    new_gameplay =
      gameplay
      |> Map.put(:playable, to_play)
      |> Map.update(:played, [just_played], &[just_played | &1])
      |> Map.update!(correctness, &(&1 + 1))

    assign(socket, :gameplay, new_gameplay)
  end

  # give a feedback map for the socket given three predicates:
  #
  # 1. the user should get feedback
  # 2. the user was correct
  # 3. the image was malignant
  @spec give_feedback(boolean(), boolean(), boolean()) :: %{}
  defp give_feedback(false, _, _), do: %{}

  defp give_feedback(true, correct?, malignant?) do
    give_feedback(correct?, malignant?)
    |> Map.put("correct", correct?)
  end

  @spec give_feedback(boolean(), boolean()) :: %{String.t() => String.t()}
  defp give_feedback(true, true),
    do: %{"feedbackpath" => "/images/correct_malignant.png"}

  defp give_feedback(true, false),
    do: %{"feedbackpath" => "/images/correct_normal.png"}

  defp give_feedback(false, true),
    do: %{"feedbackpath" => "/images/incorrect_malignant.png"}

  defp give_feedback(false, false),
    do: %{"feedbackpath" => "/images/incorrect_normal.png"}

  defp recap_path(%{
         assigns: %{
           username: username,
           set_number: set_number,
           condition: condition
         }
       }) do
    with %{survey_progress: 1} = user <- Accounts.get_user_by_uname(username),
         4 <- set_number,
         %{postlink: postlink} <- Content.get_survey(user.survey_id),
         link <- "#{postlink}?username=#{username}&condition=#{condition}" do
      {:ok, _user} = Accounts.update_user(user, %{survey_progress: 2})

      link
    else
      _ -> Routes.game_path(Endpoint, :show)
    end
  end
end
