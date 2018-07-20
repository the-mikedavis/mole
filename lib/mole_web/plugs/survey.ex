defmodule MoleWeb.Plugs.Survey do
  @moduledoc false
  import Plug.Conn

  alias Mole.Content

  def init(opts), do: opts

  def call(conn, _opts) do
    survey_id = get_session(conn, :survey_id)
    assign(conn, :survey_id, survey_id)
  end

  def load_surey(conn) do
    survey_id = conn.assigns.survey_id
    survey = survey_id && Content.get_survey!(survey_id)
    assign(conn, :current_survey, survey)
  end

  # TODO: in the following functions, add and remove the associations on the
  # Survey has_many if the current_user is defined.
  #
  # Also add that to the login process, that the survey id is read.
  def put_survey(conn, survey_id) do
    put_session(conn, :survey_id, survey_id)
  end

  def delete_survey(conn) do
    delete_session(conn, :survey_id)
  end
end
