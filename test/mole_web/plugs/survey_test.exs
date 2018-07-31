defmodule MoleWeb.Plugs.SurveyTest do
  use MoleWeb.ConnCase, async: true
  import Plug.Test

  alias Mole.{Accounts, Content}
  alias MoleWeb.Plugs.Survey

  @default_attrs %{username: "username", password: "password"}

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(@default_attrs)
      |> Accounts.create_user()

    user
  end

  @default_survey %{slug: "slug", prelink: "prelink", postlink: "postlink"}

  def survey_fixture(attrs \\ %{}) do
    {:ok, survey} =
      attrs
      |> Enum.into(@default_survey)
      |> Content.create_survey()

    survey
  end

  test "init returns whatever it got" do
    assert Survey.init(nil) == nil
    assert Survey.init(47) == 47
    assert Survey.init(%{}) == %{}
  end

  test "an assigned user with no survey_id is updated on next page visit" do
    user = user_fixture(%{survey_id: nil})
    survey = survey_fixture()

    conn =
      build_conn()
      |> init_test_session(%{})
      |> assign(:current_user, user)
      |> put_session(:survey_id, survey.id)
      |> Survey.call(%{})

    assert Accounts.get_user(user.id).survey_id == survey.id
    assert conn.assigns.survey_id == survey.id
  end

  test "putting a survey adds it to the session" do
    conn =
      build_conn()
      |> init_test_session(%{})
      |> Survey.put_survey(2)

    assert get_session(conn, :survey_id) == 2
  end

  test "loading a survey puts the survey into the assigns" do
    survey = survey_fixture()

    conn =
      build_conn()
      |> init_test_session(%{})
      |> Survey.put_survey(survey.id)
      |> Survey.call(%{})
      |> Survey.load_survey()

    assert conn.assigns.current_survey == survey
  end
end
