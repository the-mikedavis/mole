defmodule MoleWeb.Plugs.ConsentTest do
  use MoleWeb.ConnCase, async: true
  import Plug.Test

  alias MoleWeb.Plugs.Consent

  test "init returns whatever it got" do
    assert Consent.init(nil) == nil
    assert Consent.init(47) == 47
    assert Consent.init(%{}) == %{}
  end

  test "consenting puts session and assigns consent atom" do
    conn =
      build_conn()
      |> init_test_session(%{})
      |> fetch_flash()
      |> Consent.consent()

    assert conn.assigns.consent?
    assert get_session(conn, :consent?)
  end
end
