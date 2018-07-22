defmodule MoleWeb.Plugs.Consent do
  @moduledoc false
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts),
    do: assign(conn, :consent?, get_session(conn, :consent?))

  def consent(conn) do
    conn
    |> put_session(:consent?, true)
    |> assign(:consent?, true)
  end
end
