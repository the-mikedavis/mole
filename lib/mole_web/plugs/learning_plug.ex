defmodule MoleWeb.Plugs.Learning do
  import Plug.Conn

  @moduledoc "Has the user done learning yet? Look in the cookie"

  @key :learned?

  def init(opts), do: opts

  def call(conn, _opts),
    do: assign(conn, @key, get_session(conn, @key))

  def learn(conn) do
    conn
    |> put_session(@key, true)
    |> assign(@key, true)
  end
end
