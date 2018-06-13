defmodule Mole.ContentTest do
  use Mole.DataCase

  alias Mole.Content

  describe "images" do
    alias Mole.Content.Image

    @valid_attrs %{malignant: true, origin_id: "some origin_id", path: "some path"}
    @update_attrs %{
      malignant: false,
      origin_id: "some updated origin_id",
      path: "some updated path"
    }
    @invalid_attrs %{malignant: nil, origin_id: nil, path: nil}

    def image_fixture(attrs \\ %{}) do
      {:ok, image} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Content.create_image()

      image
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
      assert image.path == "some path"
    end

    test "create_image/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_image(@invalid_attrs)
    end

    test "update_image/2 with valid data updates the image" do
      image = image_fixture()
      assert {:ok, %Image{} = image} = Content.update_image(image, @update_attrs)

      assert image.malignant == false
      assert image.origin_id == "some updated origin_id"
      assert image.path == "some updated path"
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
  end
end
