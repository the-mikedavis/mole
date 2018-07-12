defmodule MoleWeb.SurveyController do
  use MoleWeb, :controller

  alias Mole.Content
  alias Mole.Content.Survey

  def index(conn, _params) do
    surveys = Content.list_surveys()
    render(conn, "index.html", surveys: surveys)
  end

  def new(conn, _params) do
    changeset = Content.change_survey(%Survey{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"survey" => survey_params}) do
    case Content.create_survey(survey_params) do
      {:ok, survey} ->
        conn
        |> put_flash(:info, "Survey created successfully.")
        |> redirect(to: Routes.survey_path(conn, :show, survey))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    survey = Content.get_survey!(id)
    render(conn, "show.html", survey: survey)
  end

  def edit(conn, %{"id" => id}) do
    survey = Content.get_survey!(id)
    changeset = Content.change_survey(survey)
    render(conn, "edit.html", survey: survey, changeset: changeset)
  end

  def update(conn, %{"id" => id, "survey" => survey_params}) do
    survey = Content.get_survey!(id)

    case Content.update_survey(survey, survey_params) do
      {:ok, survey} ->
        conn
        |> put_flash(:info, "Survey updated successfully.")
        |> redirect(to: Routes.survey_path(conn, :show, survey))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", survey: survey, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    survey = Content.get_survey!(id)
    {:ok, _survey} = Content.delete_survey(survey)

    conn
    |> put_flash(:info, "Survey deleted successfully.")
    |> redirect(to: Routes.survey_path(conn, :index))
  end
end
