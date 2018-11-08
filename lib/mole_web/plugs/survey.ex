defmodule MoleWeb.Plugs.Survey do
  @moduledoc false
  import Plug.Conn

  alias Mole.{Accounts, Accounts.User}
  alias MoleWeb.Plugs.Condition

  @key :survey_id
  @sp :survey_progress

  def init(opts), do: opts

  def call(conn, _opts) do
    user = conn.assigns[:current_user]
    survey_id = (user && user.survey_id) || get_session(conn, @key)

    with %User{@key => nil} <- user,
         id when not is_nil(id) <- survey_id,
         do: Accounts.update_user(user, %{@key => id, @sp => 0})

    assign(conn, @key, survey_id)
  end

  def put_survey(conn, survey_id) do
    conn
    |> Condition.put_random(survey_id)
    |> assign(@key, survey_id)
    |> put_session(@key, survey_id)
    |> configure_session(renew: true)
  end

  # survey progress things

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
