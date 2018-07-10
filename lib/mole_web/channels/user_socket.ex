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

  @user_socket_secret Application.get_env(:mole, :user_socket_secret)

  channel("game:*", MoleWeb.GameChannel)

  def connect(%{"token" => token}, socket) do
    socket
    |> Phoenix.Token.verify(@user_socket_secret, token, max_age: 1_209_600)
    |> case do
      {:ok, uname} ->
        {:ok, assign(socket, :username, uname)}

      {:error, _reason} ->
        :error
    end
  end

  # these sockets should be anonymous
  def id(_socket), do: nil
end
