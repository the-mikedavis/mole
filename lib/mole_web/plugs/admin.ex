defmodule MoleWeb.Plugs.Admin do
  @moduledoc false
  import Plug.Conn

  alias Mole.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    assign(conn, :admin?, conn.assigns[:admin_id] && Accounts.is_admin?(conn.assigns[:admin_id]))
  end
end
