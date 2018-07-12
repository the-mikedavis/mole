defmodule MoleWeb.AdminAuth do
  @moduledoc false
  import Phoenix.Controller
  import Plug.Conn

  alias Mole.Administrators
  alias MoleWeb.Router.Helpers, as: Routes

  def init(opts), do: opts

  def call(conn, _opts) do
    with %{username: username} <- conn.assigns.current_user,
         true <- Administrators.is?(username) do
      conn
    else
      _ ->
        conn
        |> put_flash(
          :error,
          "You do not have proper permissions to access that page."
        )
        |> redirect(to: Routes.session_path(conn, :new))
        |> halt()
    end
  end
end
