defmodule MoleWeb.UserSocket do
  use Phoenix.Socket

  @moduledoc """
  The user socket.

  It waits for a connction on the `game` topic. On trying to connect, it
  verifies the user. It allows them to play if they have a token. Else
  they cannot play.

  It also saves the current user id to the socket, allowing saving of a
  potential user later.
  """

  channel("game:*", MoleWeb.GameChannel)

  # two weeks
  def connect(%{"token" => token}, socket) do
    socket
    |> Phoenix.Token.verify(MoleWeb.signing_token(), token, max_age: 1_209_600)
    |> case do
      {:ok, user_id} ->
        {:ok, assign(socket, :user_id, user_id)}

      {:error, _reason} ->
        :error
    end
  end

  # these sockets should be anonymous
  def id(_socket), do: nil
end
