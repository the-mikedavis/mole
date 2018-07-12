defmodule MoleWeb.SurveyControllerTest do
  use MoleWeb.ConnCase

  alias Mole.Content

  @create_attrs %{link: "some link", slug: "some slug"}
  @update_attrs %{link: "some updated link", slug: "some updated slug"}
  @invalid_attrs %{link: nil, slug: nil}

  def fixture(:survey) do
    {:ok, survey} = Content.create_survey(@create_attrs)
    survey
  end

  describe "index" do
    test "lists all surveys", %{conn: conn} do
      conn = get conn, Routes.survey_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Surveys"
    end
  end

  describe "new survey" do
    test "renders form", %{conn: conn} do
      conn = get conn, Routes.survey_path(conn, :new)
      assert html_response(conn, 200) =~ "New Survey"
    end
  end

  describe "create survey" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, Routes.survey_path(conn, :create), survey: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.survey_path(conn, :show, id)

      conn = get conn, Routes.survey_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Survey"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, Routes.survey_path(conn, :create), survey: @invalid_attrs
      assert html_response(conn, 200) =~ "New Survey"
    end
  end

  describe "edit survey" do
    setup [:create_survey]

    test "renders form for editing chosen survey", %{conn: conn, survey: survey} do
      conn = get conn, Routes.survey_path(conn, :edit, survey)
      assert html_response(conn, 200) =~ "Edit Survey"
    end
  end

  describe "update survey" do
    setup [:create_survey]

    test "redirects when data is valid", %{conn: conn, survey: survey} do
      conn = put conn, Routes.survey_path(conn, :update, survey), survey: @update_attrs
      assert redirected_to(conn) == Routes.survey_path(conn, :show, survey)

      conn = get conn, Routes.survey_path(conn, :show, survey)
      assert html_response(conn, 200) =~ "some updated link"
    end

    test "renders errors when data is invalid", %{conn: conn, survey: survey} do
      conn = put conn, Routes.survey_path(conn, :update, survey), survey: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Survey"
    end
  end

  describe "delete survey" do
    setup [:create_survey]

    test "deletes chosen survey", %{conn: conn, survey: survey} do
      conn = delete conn, Routes.survey_path(conn, :delete, survey)
      assert redirected_to(conn) == Routes.survey_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, Routes.survey_path(conn, :show, survey)
      end
    end
  end

  defp create_survey(_) do
    survey = fixture(:survey)
    {:ok, survey: survey}
  end
end
