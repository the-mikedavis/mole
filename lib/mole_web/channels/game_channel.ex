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
          playable: [map()],
          played: [map()],
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
    {set_number, set} = GameplayServer.new_set(socket.assigns.user_id)

    %User{condition: condition} = Accounts.get_user!(socket.assigns.user_id)

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
  def handle_in("answer", %{"malignant" => malignant?, "time_spent" => time}, socket) do
    malignant = current_image(socket).malignant
    correct? = malignant == malignant?
    socket = update_gameplay(socket, %{correct?: correct?, time_spent: time})

    feedback =
      if socket.assigns.set_number === 1,
        do: Condition.feedback(socket.assigns.condition),
        else: :none

    feedback_map =
      give_feedback(feedback, correct?, malignant, length(socket.assigns.gameplay.played) - 1)

    reply =
      case socket.assigns.gameplay.playable do
        [] ->
          GameplayServer.save_set(
            socket.assigns.user_id,
            socket.assigns.gameplay
          )

          Map.merge(feedback_map, %{
            "reroute" => true,
            "path" => recap_path(socket)
          })

        _list ->
          Map.put(feedback_map, "path", current_image_path(socket))
      end
      |> Map.put("remaining", length(socket.assigns.gameplay.playable))

    {:reply, {:ok, reply}, socket}
  end

  @spec gameplay(GameplayServer.set()) :: gameplay()
  defp gameplay(set), do: %{playable: set, correct: 0, incorrect: 0, bonus: 0, played: []}

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
  defp update_gameplay(%{assigns: %{gameplay: gameplay}} = socket, response) do
    correctness = if response.correct?, do: :correct, else: :incorrect
    [just_played | to_play] = gameplay.playable

    # add in the correctness and time spent
    just_played = Map.merge(just_played, response)

    new_gameplay =
      gameplay
      |> Map.put(:playable, to_play)
      |> Map.update(:played, [just_played], &[just_played | &1])
      |> Map.update!(correctness, &(&1 + 1))

    assign(socket, :gameplay, new_gameplay)
  end

  @spec give_feedback(atom(), boolean(), boolean(), integer()) :: %{}
  defp give_feedback(:none, _, _, _), do: %{}

  defp give_feedback(:standard, correct?, malignant?, _image_number) do
    give_feedback(correct?, malignant?)
    |> Map.put("correct", correct?)
  end

  defp give_feedback(:motivational, correct?, malignant?, n) when n in [0, 3, 6, 9] do
    give_feedback(:standard, correct?, malignant?, n)
    |> give_motivation(div(n, 3))
  end

  defp give_feedback(:motivational, correct?, malignant?, n) do
    give_feedback(:standard, correct?, malignant?, n)
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

  @motivation_texts [
    "More skin cancers are diagnosed in the US each year than all other cancers combined.",
    "Melanoma is the most lethal common form of skin cancer, accounting for about 72% of all skin cancer deaths in the US.",
    "Self-examination is easy and should take no more than 10 minutes – a small investment in what could be a life-saving procedure.",
    "Monthly thorough skin self-examinations reduce your risk of dying from melanoma. Identify suspicious moles early and alert your doctor!"
  ]
  @motivation_paths Enum.map(0..3, fn n -> "/images/motivation_#{n}.png" end)

  @spec give_motivation(map(), 0 | 1 | 2 | 3) :: map()
  defp give_motivation(feedback_map, image_number) do
    feedback_map
    |> Map.put("motivation_text", Enum.at(@motivation_texts, image_number))
    |> Map.put("motivation_path", Enum.at(@motivation_paths, image_number))
  end

  defp recap_path(%{
         assigns: %{
           user_id: user_id,
           set_number: set_number,
           condition: condition
         }
       }) do
    with %{survey_progress: 1} = user <- Accounts.get_user!(user_id),
         4 <- set_number,
         {:ok, _user} <- Accounts.update_user(user, %{survey_progress: 2}),
         %{postlink: postlink} when not is_nil(postlink) <- Content.get_survey(user.survey_id) do
      "#{postlink}?user_id=#{user_id}&condition=#{condition}"
    else
      _ -> Routes.game_path(Endpoint, :show)
    end
  end
end
