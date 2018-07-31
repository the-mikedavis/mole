defmodule MoleWeb.Plugs.Survey do
  @moduledoc false
  import Plug.Conn

  alias Mole.{Accounts, Accounts.User, Content}

  @key :survey_id

  def init(opts), do: opts

  def call(conn, _opts) do
    user = conn.assigns[:current_user]
    survey_id = (user && user.survey_id) || get_session(conn, @key)

    with %User{@key => nil} <- user,
         do: Accounts.update_user(user, %{@key => survey_id})

    assign(conn, @key, survey_id)
  end

  def load_survey(conn) do
    survey_id = conn.assigns.survey_id
    survey = survey_id && Content.get_survey!(survey_id)
    assign(conn, :current_survey, survey)
  end

  def put_survey(conn, survey_id), do: put_session(conn, @key, survey_id)
end
