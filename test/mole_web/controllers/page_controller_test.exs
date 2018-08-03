defmodule MoleWeb.PageControllerTest do
  use MoleWeb.ConnCase, async: true

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Welcome to Whack-a-Mole!"
  end
end
