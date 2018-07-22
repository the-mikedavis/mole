defmodule MoleWeb.Plugs.Condition do
  @moduledoc false
  import Plug.Conn

  alias Mole.{Accounts, Accounts.User}

  # dry
  @key :condition

  @eds [:abcde, :duckling, :none]
  @feedback [true, false]
  # the cartesian product of the above
  @conditions for ed <- @eds, fb <- @feedback, do: {ed, fb}

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
      put_session(conn, @key, Enum.random(0..5))
    end
  end

  # get back the useful information from the conditions
  def to_tuple(index), do: Enum.at(@conditions, index)
end
