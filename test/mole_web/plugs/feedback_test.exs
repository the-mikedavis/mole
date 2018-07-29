defmodule MoleWeb.Plugs.FeedbackTest do
  use MoleWeb.ConnCase, async: true

  alias Mole.Accounts.User
  alias MoleWeb.Plugs.Feedback

  test "init returns whatever it got" do
    assert Feedback.init(nil) == nil
    assert Feedback.init(47) == 47
    assert Feedback.init(%{}) == %{}
  end

  test "feedback given a feedback condition" do
    feedbacked =
      build_conn()
      |> assign(:current_user, %User{condition: 0})
      |> Feedback.call(nil)

    assert feedbacked.assigns.feedback
  end
end
