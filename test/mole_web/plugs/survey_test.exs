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

  test "an assigned user with no survey_id is given survey_progress on visit" do
    user = user_fixture(%{survey_id: nil})
    survey = survey_fixture()

    build_conn()
    |> init_test_session(%{})
    |> assign(:current_user, user)
    |> put_session(:survey_id, survey.id)
    |> Survey.call(%{})

    assert Accounts.get_user(user.id).survey_id == survey.id
    assert Accounts.get_user(user.id).survey_progress == 0
  end

  test "putting a survey adds it to the session" do
    conn =
      build_conn()
      |> init_test_session(%{})
      |> Survey.put_survey(2)

    assert get_session(conn, :survey_id) == 2
  end

  test "getting a pre_survey is accurate" do
    build_conn()
    |> assign(
      :current_user,
      user_fixture(%{username: "user0", survey_progress: 0})
    )
    |> Survey.pre_survey?()
    |> assert()

    build_conn()
    |> assign(
      :current_user,
      user_fixture(%{username: "user1", survey_progress: 1})
    )
    |> Survey.pre_survey?()
    |> Kernel.not()
    |> assert()

    build_conn()
    |> assign(
      :current_user,
      user_fixture(%{username: "user2", survey_progress: 2})
    )
    |> Survey.pre_survey?()
    |> Kernel.not()
    |> assert()

    build_conn()
    |> Survey.pre_survey?()
    |> Kernel.not()
    |> assert()
  end

  test "getting a post_survey is accurate" do
    build_conn()
    |> assign(
      :current_user,
      user_fixture(%{username: "user0", survey_progress: 0})
    )
    |> Survey.post_survey?()
    |> assert()

    build_conn()
    |> assign(
      :current_user,
      user_fixture(%{username: "user1", survey_progress: 1})
    )
    |> Survey.post_survey?()
    |> assert()

    build_conn()
    |> assign(
      :current_user,
      user_fixture(%{username: "user2", survey_progress: 2})
    )
    |> Survey.post_survey?()
    |> Kernel.not()
    |> assert()

    build_conn()
    |> Survey.post_survey?()
    |> Kernel.not()
    |> assert()
  end

  test "checking updates the user" do
    user = user_fixture(%{survey_progress: 0})

    conn =
      build_conn()
      |> assign(:current_user, user)

    checked = Survey.check(conn)

    assert checked.assigns.current_user.survey_progress == 1
  end

  test "if the user doesn't exist, it won't be checked" do
    conn = build_conn()

    checked = Survey.check(conn)

    assert conn == checked
  end
end
