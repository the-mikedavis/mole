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

  def put_survey(conn, survey_id) do
    conn
    |> assign(@key, survey_id)
    |> put_session(@key, survey_id)
    |> configure_session(renew: true)
  end

  @sp :survey_progress

  def pre_survey?(%{assigns: %{current_user: %{@sp => 0}}}), do: true
  def pre_survey?(_conn), do: false

  def post_survey?(%{assigns: %{current_user: %{@sp => n}}}) when n in 0..1,
    do: true

  def post_survey?(_conn), do: false

  def check(%{assigns: %{current_user: %{@sp => n} = user}} = conn)
      when is_integer(n) do
    {:ok, user} = Accounts.update_user(user, %{@sp => n + 1})

    assign(conn, :current_user, user)
  end

  def check(conn), do: conn
end
