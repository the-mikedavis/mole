defmodule MoleWeb.SessionControllerTest do
  use MoleWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/sessions/new")
    assert html_response(conn, 200) =~ "Log in"
  end
end
