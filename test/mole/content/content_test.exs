defmodule Mole.ContentTest do
  use Mole.DataCase, async: true

  alias Mole.Content

  describe "database operations on the images table" do
    alias Mole.Content.Image

    @valid_attrs %{
      malignant: true,
      origin_id: "some origin_id"
    }
    @update_attrs %{
      malignant: false,
      origin_id: "some updated origin_id"
    }
    @invalid_attrs %{malignant: nil, origin_id: nil}

    def image_fixture(attrs \\ %{}) do
      {:ok, image} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Content.create_image()

      image
    end

    setup do
      Repo.delete_all(Mole.Content.Image)

      :ok
    end

    test "get_image!/1 returns the image with given id" do
      image = image_fixture()
      assert Content.get_image!(image.id) == image
    end

    test "create_image/1 with valid data creates a image" do
      assert {:ok, %Image{} = image} = Content.create_image(@valid_attrs)
      assert image.malignant == true
      assert image.origin_id == "some origin_id"
    end

    test "create_image/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_image(@invalid_attrs)
    end

    test "update_image/2 with valid data updates the image" do
      image = image_fixture()

      assert {:ok, %Image{} = image} = Content.update_image(image, @update_attrs)

      assert image.malignant == false
      assert image.origin_id == "some updated origin_id"
    end

    test "update_image/2 with invalid data returns error changeset" do
      image = image_fixture()

      assert {:error, %Ecto.Changeset{}} = Content.update_image(image, @invalid_attrs)

      assert image == Content.get_image!(image.id)
    end

    test "delete_image/1 deletes the image" do
      image = image_fixture()
      assert {:ok, %Image{}} = Content.delete_image(image)
      assert_raise Ecto.NoResultsError, fn -> Content.get_image!(image.id) end
    end

    test "change_image/1 returns a image changeset" do
      image = image_fixture()
      assert %Ecto.Changeset{} = Content.change_image(image)
    end

    test "can calculate the percent malignant" do
      # malignant
      image_fixture()
      # non-malignant
      image_fixture(@update_attrs)

      assert Content.percent_malignant() === 50
    end
  end

  describe "path building" do
    setup do
      [
        static: "/images/moles/X.png",
        download: "priv/static/images/X.png"
      ]
    end

    test "a static path given a String `id`", c do
      assert Content.static_path("X") == c.static
    end

    test "a static path given a faux image map", c do
      assert Content.static_path(%{id: "X"}) == c.static
      assert Content.static_path(%{origin_id: "X"}) == c.static
    end
  end

  describe "surveys" do
    alias Mole.Content.Survey

    @valid_attrs %{
      postlink: "some postlink",
      prelink: "some prelink",
      slug: "someslug"
    }
    @update_attrs %{
      postlink: "some updated postlink",
      prelink: "some updated prelink",
      slug: "someupdatedslug"
    }
    @invalid_attrs %{postlink: nil, prelink: nil, slug: "some slug"}

    def survey_fixture(attrs \\ %{}) do
      {:ok, survey} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Content.create_survey()

      survey
    end

    test "list_surveys/0 returns all surveys" do
      survey = survey_fixture()
      assert Content.list_surveys() == [survey]
    end

    test "get_survey!/1 returns the survey with given id" do
      survey = survey_fixture()
      assert Content.get_survey!(survey.id) == survey
    end

    test "create_survey/1 with valid data creates a survey" do
      assert {:ok, %Survey{} = survey} = Content.create_survey(@valid_attrs)
      assert survey.postlink == "some postlink"
      assert survey.prelink == "some prelink"
      assert survey.slug == "someslug"
    end

    test "create_survey/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_survey(@invalid_attrs)
    end

    test "update_survey/2 with valid data updates the survey" do
      survey = survey_fixture()

      assert {:ok, %Survey{} = survey} = Content.update_survey(survey, @update_attrs)

      assert survey.postlink == "some updated postlink"
      assert survey.prelink == "some updated prelink"
      assert survey.slug == "someupdatedslug"
    end

    test "update_survey/2 with invalid data returns error changeset" do
      survey = survey_fixture()

      assert {:error, %Ecto.Changeset{}} = Content.update_survey(survey, @invalid_attrs)

      assert survey == Content.get_survey!(survey.id)
    end

    test "delete_survey/1 deletes the survey" do
      survey = survey_fixture()
      assert {:ok, %Survey{}} = Content.delete_survey(survey)
      assert_raise Ecto.NoResultsError, fn -> Content.get_survey!(survey.id) end
    end

    test "change_survey/1 returns a survey changeset" do
      survey = survey_fixture()
      assert %Ecto.Changeset{} = Content.change_survey(survey)
    end

    test "get a survey by slug" do
      survey = survey_fixture()
      assert Content.get_survey_by_slug("someslug") == survey.id
    end
  end

  describe "answers" do
    alias Mole.Content.Answer

    @valid_attrs %{correct: true}
    @update_attrs %{correct: false}
    @invalid_attrs %{correct: nil}

    def answer_fixture(attrs \\ %{}) do
      {:ok, answer} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Content.create_answer()

      answer
    end

    test "list_answers/0 returns all answers" do
      answer = answer_fixture()
      assert Content.list_answers() == [answer]
    end

    test "get_answer!/1 returns the answer with given id" do
      answer = answer_fixture()
      assert Content.get_answer!(answer.id) == answer
    end

    test "create_answer/1 with valid data creates a answer" do
      assert {:ok, %Answer{} = answer} = Content.create_answer(@valid_attrs)
      assert answer.correct == true
    end

    test "create_answer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_answer(@invalid_attrs)
    end

    test "update_answer/2 with valid data updates the answer" do
      answer = answer_fixture()

      assert {:ok, %Answer{} = answer} = Content.update_answer(answer, @update_attrs)

      assert answer.correct == false
    end

    test "update_answer/2 with invalid data returns error changeset" do
      answer = answer_fixture()

      assert {:error, %Ecto.Changeset{}} = Content.update_answer(answer, @invalid_attrs)

      assert answer == Content.get_answer!(answer.id)
    end

    test "delete_answer/1 deletes the answer" do
      answer = answer_fixture()
      assert {:ok, %Answer{}} = Content.delete_answer(answer)
      assert_raise Ecto.NoResultsError, fn -> Content.get_answer!(answer.id) end
    end

    test "change_answer/1 returns a answer changeset" do
      answer = answer_fixture()
      assert %Ecto.Changeset{} = Content.change_answer(answer)
    end
  end
end
