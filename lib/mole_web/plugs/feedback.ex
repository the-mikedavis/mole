defmodule MoleWeb.Plugs.Feedback do
  @moduledoc "Decide whether or not the user should have feedback"

  import Plug.Conn

  alias Mole.{Accounts.User, Content.Condition}

  def init(opts), do: opts

  def call(conn, _opts) do
    feedback =
      case conn.assigns[:current_user] do
        %User{condition: con} -> Condition.feedback(con)
        _ -> :standard
      end

    assign(conn, :feedback, feedback)
  end
end
