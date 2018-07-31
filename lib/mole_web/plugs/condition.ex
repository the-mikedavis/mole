defmodule MoleWeb.Plugs.Condition do
  @moduledoc false
  import Plug.Conn

  alias Mole.{Accounts, Accounts.User, Content.Condition}

  # dry
  @key :condition

  def init(opts), do: opts

  def call(conn, _opts) do
    user = conn.assigns[:current_user]

    condition =
      (user && user.condition) || get_session(conn, @key) || Condition.normal()

    with %User{@key => nil} <- user,
         do: Accounts.update_user(user, %{@key => condition})

    assign(conn, @key, condition)
  end

  # give a random condition to a user
  def put_random(conn) do
    condition = Condition.random()

    conn
    |> put_session(@key, condition)
    |> assign(@key, condition)
  end

  # def redirect(conn) do
  # end
end
