defmodule Mole.Content do
  @moduledoc """
  The Content context. Stores interesting information about the game, like the
  images and the statistics.
  """

  import Ecto.Query, warn: false
  alias Mole.Repo

  alias Mole.Content.Image

  @doc """
  Returns the list of images.

  ## Examples

      iex> list_images()
      [%Image{}, ...]

  """
  def list_images do
    Repo.all(Image)
  end

  @doc """
  Gets a single image.

  Raises `Ecto.NoResultsError` if the Image does not exist.

  ## Examples

      iex> get_image!(123)
      %Image{}

      iex> get_image!(456)
      ** (Ecto.NoResultsError)

  """
  def get_image!(id), do: Repo.get!(Image, id)

  @doc """
  Creates a image.

  ## Examples

      iex> create_image(%{field: value})
      {:ok, %Image{}}

      iex> create_image(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_image(attrs \\ %{}) do
    %Image{}
    |> Image.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a image.

  ## Examples

      iex> update_image(image, %{field: new_value})
      {:ok, %Image{}}

      iex> update_image(image, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_image(%Image{} = image, attrs) do
    image
    |> Image.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Image.

  ## Examples

      iex> delete_image(image)
      {:ok, %Image{}}

      iex> delete_image(image)
      {:error, %Ecto.Changeset{}}

  """
  def delete_image(%Image{} = image) do
    Repo.delete(image)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking image changes.

  ## Examples

      iex> change_image(image)
      %Ecto.Changeset{source: %Image{}}

  """
  def change_image(%Image{} = image) do
    Image.changeset(image, %{})
  end

  @doc """
  Count the number of images in the repo.
  """
  def count_images(), do: Repo.aggregate(Image, :count, :id)

  @doc """
  Determine if an image is malignant or not.
  """
  @spec malignant?(String.t()) :: {:ok, boolean()} | :error
  def malignant?(id) do
    case Repo.get(Image, id) do
      %Image{malignant: malignant?} ->
        {:ok, malignant?}

      _ ->
        :error
    end
  end

  # Ecto query to select malignant images
  @malignant_query from(
                     i in "images",
                     where: [malignant: "TRUE"],
                     select: i.id
                   )

  # Get the percent of malignant images in the local datastore.
  @spec percent_malignant() :: float()
  def percent_malignant() do
    total_amount = count_images()

    @malignant_query
    |> Mole.Repo.aggregate(:count, :id)
    |> Kernel./(total_amount)
    |> Kernel.*(100)
    |> round()
  end

  @doc """
  Retreive a random image from the repo.
  """
  @spec random_images(integer()) :: [%Image{} | :error]
  def random_images(count) do
    size = count_images() + 1

    1..size
    |> Enum.take_random(count * 2)
    |> Enum.uniq()
    |> Enum.take(count)
    |> Enum.map(&Repo.get(Image, &1))
  end

  @doc "Produce a static path in which to access the image"
  @spec static_path(String.t() | map()) :: String.t()
  def static_path(id) when is_binary(id), do: "/images/#{id}.jpeg"
  def static_path(%{origin_id: id}), do: static_path(id)
  def static_path(%{id: id}), do: static_path(id)

  @doc "Produce a download path in which to save the image"
  @spec download_path(String.t() | map()) :: String.t()
  def download_path(id) when is_binary(id),
    do: "./priv/static" <> static_path(id)

  def download_path(%{origin_id: id}), do: download_path(id)
  def download_path(%{id: id}), do: download_path(id)

  # TODO: place this in with the survey content
  # def get_survey_by_slug(slug) do
  # from(s in "surveys", where: [slug: ^slug], select: s.id)
  # |> Repo.one()
  # end
end
