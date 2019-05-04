defmodule MoleWeb.GameController do
  use MoleWeb, :controller

  require Logger

  alias Mole.{Accounts, Content}
  alias MoleWeb.Plugs.Survey

  # order matters here
  plug(:logged_in)
  plug(:consent)
  plug(:pre_survey when action == :index)
  plug(:learn)
  # plug(:post_survey when action == :show)

  alias Mole.GameplayServer

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def show(conn, _params) do
    sets_left = GameplayServer.sets_left(conn.assigns.current_user.id)

    render(conn, "show.html", sets_left: sets_left)
  end

  # ensure the user is logged in before they access a game
  defp logged_in(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      {:ok, user} = Accounts.create_user()

      conn
      |> put_session(:user_id_token, encrypt(conn, user.id))
      |> assign(:user_id, user.id)
      |> assign(:current_user, user)
      |> configure_session(renew: true)
    end
  end

  defp encrypt(conn, data), do: Phoenix.Token.sign(conn, MoleWeb.signing_token(), data)

  defp consent(conn, _opts) do
    if conn.assigns.survey_id && !conn.assigns.consent? do
      conn
      |> redirect(to: Routes.consent_path(conn, :index))
      |> halt()
    else
      conn
    end
  end

  defp learn(conn, _opts) do
    if conn.assigns[:learned?] do
      conn
    else
      conn
      |> redirect(to: Routes.learning_path(conn, :show, 0))
      |> halt()
    end
  end

  defp pre_survey(conn, _opts) do
    with true <- Survey.pre_survey?(conn),
         %{prelink: prelink} <- Content.get_survey(conn.assigns.survey_id),
         link <- link(prelink, conn) do
      conn
      |> Survey.check()
      |> redirect(external: link)
      |> halt()
    else
      _ -> conn
    end
  end

  # build a link that gives the username and condition as query parameters
  defp link(link, conn) do
    link <>
      "?username=" <>
      conn.assigns.current_user.username <> "&condition=#{conn.assigns.current_user.condition}"
  end
end
