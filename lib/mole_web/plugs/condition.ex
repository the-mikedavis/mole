defmodule MoleWeb.Plugs.Condition do
  @moduledoc false
  import Plug.Conn

  alias Mole.{Accounts, Accounts.User, Content.Condition}

  # dry
  @key :condition

  def init(opts), do: opts

  def call(conn, _opts) do
    condition = get_session(conn, @key)

    with %User{condition: nil} = user <- conn.assigns.current_user,
         do: Accounts.update_user(user, %{condition: condition})

    assign(conn, @key, condition)
  end

  # give a random condition to a user
  def put_random(conn) do
    if conn.assigns.condition do
      conn
    else
      put_session(conn, @key, Condition.random())
    end
  end

  # def redirect(conn) do
  # end
end
