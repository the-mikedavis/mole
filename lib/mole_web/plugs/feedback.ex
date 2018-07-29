defmodule MoleWeb.Plugs.Feedback do
  import Plug.Conn

  alias Mole.{Accounts.User, Content.Condition}

  def init(opts), do: opts

  def call(conn, _opts) do
    feedback? =
      case conn.assigns do
        %{current_user: %User{condition: con}} -> Condition.feedback?(con)
        _ -> true
      end

    assign(conn, :feedback, feedback?)
  end
end
