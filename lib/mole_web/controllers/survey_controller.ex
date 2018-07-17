defmodule MoleWeb.SurveyController do
  use MoleWeb, :controller

  alias Mole.{Content, Content.Survey}
  alias MoleWeb.Plugs

  plug(Plugs.Admin when action != :join)
  plug(Plugs.Survey when action == :join)

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

  def join(conn, %{"slug" => slug}) do
    case Content.get_survey_by_slug(slug) do
      nil ->
        conn
        |> put_flash(:error, "Couldn't find the \"#{slug}\" survey.")
        |> redirect(to: Routes.page_path(conn, :index))

      id ->
        conn
        |> Plugs.Survey.put_survey(id)
        |> put_flash(:info, "You have joined survey \"#{slug}\".")
        |> redirect(to: Routes.game_path(conn, :index))
    end
  end
end
