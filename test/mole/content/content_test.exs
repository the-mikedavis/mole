defmodule Mole.ContentTest do
  use Mole.DataCase

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

    test "list_images/0 returns all images" do
      image = image_fixture()
      assert Content.list_images() == [image]
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

      assert {:ok, %Image{} = image} =
               Content.update_image(image, @update_attrs)

      assert image.malignant == false
      assert image.origin_id == "some updated origin_id"
    end

    test "update_image/2 with invalid data returns error changeset" do
      image = image_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Content.update_image(image, @invalid_attrs)

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

    test "getting a random image" do
      image1 = image_fixture(%{id: 1})
      assert Content.random_images(1) == [image1]

      image2 = image_fixture(@update_attrs)
      [rand] = Content.random_images(1)
      assert rand == image1 or rand == image2

      together = MapSet.new([image1, image2])
      rand_together = Content.random_images(2) |> MapSet.new()
      assert MapSet.equal?(together, rand_together)
    end
  end

  describe "path building" do
    setup do
      [
        static: "/images/X.jpeg",
        download: "./priv/static/images/X.jpeg"
      ]
    end

    test "a static path given a String `id`", c do
      assert Content.static_path("X") == c.static
    end

    test "a static path given a faux image map", c do
      assert Content.static_path(%{id: "X"}) == c.static
      assert Content.static_path(%{origin_id: "X"}) == c.static
    end

    test "the download path", c do
      assert Content.download_path("X") == c.download
      assert Content.download_path(%{id: "X"}) == c.download
      assert Content.download_path(%{origin_id: "X"}) == c.download
    end
  end

  describe "surveys" do
    alias Mole.Content.Survey

    @valid_attrs %{
      postlink: "some postlink",
      prelink: "some prelink",
      slug: "some slug"
    }
    @update_attrs %{
      postlink: "some updated postlink",
      prelink: "some updated prelink",
      slug: "some updated slug"
    }
    @invalid_attrs %{postlink: nil, prelink: nil, slug: nil}

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
      assert survey.slug == "some slug"
    end

    test "create_survey/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_survey(@invalid_attrs)
    end

    test "update_survey/2 with valid data updates the survey" do
      survey = survey_fixture()

      assert {:ok, %Survey{} = survey} =
               Content.update_survey(survey, @update_attrs)

      assert survey.postlink == "some updated postlink"
      assert survey.prelink == "some updated prelink"
      assert survey.slug == "some updated slug"
    end

    test "update_survey/2 with invalid data returns error changeset" do
      survey = survey_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Content.update_survey(survey, @invalid_attrs)

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
      assert Content.get_survey_by_slug("some slug") == survey.id
    end
  end
end
