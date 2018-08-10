defmodule MoleWeb.Plugs.Consent do
  import Plug.Conn

  @moduledoc "Has the user consented to playing? Look in the cookie"

  @key :consent?

  def init(opts), do: opts

  def call(conn, _opts),
    do: assign(conn, @key, get_session(conn, @key))

  def consent(conn) do
    conn
    |> put_session(@key, true)
    |> assign(@key, true)
  end
end
