defmodule MoleWeb.Plugs.Admin do
  @moduledoc false
  import Plug.Conn

  alias Mole.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    assign(
      conn,
      :admin?,
      not is_nil(conn.assigns[:admin_id]) and Accounts.is_admin?(conn.assigns[:admin_id])
    )
  end
end
