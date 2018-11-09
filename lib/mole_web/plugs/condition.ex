defmodule MoleWeb.Plugs.Condition do
  @moduledoc false
  import Plug.Conn

  alias Mole.{
    Accounts,
    Accounts.User,
    Content,
    Content.Condition,
    Content.Survey,
    Content.SurveyServer
  }

  # dry
  @key :condition

  def init(opts), do: opts

  def call(conn, _opts) do
    user = conn.assigns[:current_user]

    condition = (user && user.condition) || get_session(conn, @key)

    with %User{@key => nil} <- user,
         do: Accounts.update_user(user, %{@key => condition})

    assign(conn, @key, condition)
  end

  # give a random condition to a user
  def put_random(conn) do
    _put_random(conn, Condition.random())
  end

  # give a forced condition, if there is one
  def put_random(conn, survey_id) do
    condition =
      case Content.get_survey(survey_id) do
        # forced condition
        %Survey{force: c} when is_integer(c) -> c
        # take a random one with even cell size
        %Survey{slug: name} -> SurveyServer.take_random(name)
        # fall back to taking a plain random
        _ -> Condition.random()
      end

    _put_random(conn, condition)
  end

  defp _put_random(conn, condition) do
    conn
    |> put_session(@key, condition)
    |> assign(@key, condition)
  end
end
