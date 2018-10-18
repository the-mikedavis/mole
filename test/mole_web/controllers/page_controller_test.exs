defmodule MoleWeb.PageControllerTest do
  use MoleWeb.ConnCase, async: true

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Ready to play?"
  end
end
