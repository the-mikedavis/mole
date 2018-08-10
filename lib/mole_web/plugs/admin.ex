defmodule MoleWeb.Plugs.Admin do
  @moduledoc false
  import Phoenix.Controller
  import Plug.Conn

  alias Mole.Administrators

  def init(opts), do: opts

  def call(conn, _opts) do
    with %{username: username} <- conn.assigns[:current_user],
         true <- Administrators.is?(username) do
      assign(conn, :admin?, true)
    else
      _ -> assign(conn, :admin?, false)
    end
  end
end
