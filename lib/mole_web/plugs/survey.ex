defmodule MoleWeb.Plugs.Survey do
  @moduledoc false
  import Plug.Conn

  alias Mole.{Accounts, Accounts.User, Content}

  def init(opts), do: opts

  def call(conn, _opts) do
    survey_id = get_session(conn, :survey_id)

    with %User{survey_id: nil} = user <- conn.assigns.current_user,
         do: Accounts.update_user(user, %{survey_id: survey_id})

    assign(conn, :survey_id, survey_id)
  end

  def load_surey(conn) do
    survey_id = conn.assigns.survey_id
    survey = survey_id && Content.get_survey!(survey_id)
    assign(conn, :current_survey, survey)
  end

  def put_survey(conn, survey_id) do
    put_session(conn, :survey_id, survey_id)
  end

  def delete_survey(conn) do
    delete_session(conn, :survey_id)
  end
end