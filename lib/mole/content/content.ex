defmodule Mole.Content do
  use Private

  @moduledoc """
  The Content context. Stores interesting information about the game, like the
  images and the statistics.
  """

  import Ecto.Query, warn: false
  alias Mole.Repo

  alias Mole.Accounts.User
  alias Mole.Content.{Answer, Condition, Image, Set, Survey, SurveyServer}

  def list_images do
    1..4
    |> Enum.map(&get_images_by_set/1)
    |> List.flatten()
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
  Get a set of images by set number
  """
  def get_images_by_set(set_number) do
    from(s in Set, select: s, where: [id: ^set_number], preload: :images)
    |> Repo.one()
    |> Map.get(:images)
  end

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

  # Ecto query to select malignant images
  @malignant_query from(
                     i in "images",
                     where: [malignant: true],
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

  @doc "Produce a static path in which to access the image"
  @spec static_path(String.t() | map()) :: String.t()
  def static_path(id) when is_binary(id), do: "/images/moles/#{id}.png"
  def static_path(%{origin_id: id}), do: static_path(id)
  def static_path(%{id: id}), do: static_path(id)

  @doc """
  Returns the list of surveys.

  ## Examples

      iex> list_surveys()
      [%Survey{}, ...]

  """
  def list_surveys do
    Repo.all(Survey)
  end

  @doc """
  Gets a single survey.

  Raises `Ecto.NoResultsError` if the Survey does not exist.

  ## Examples

      iex> get_survey!(123)
      %Survey{}

      iex> get_survey!(456)
      ** (Ecto.NoResultsError)

  """
  def get_survey!(id), do: Repo.get!(Survey, id)

  def get_survey(id), do: Repo.get(Survey, id)

  @doc """
  Creates a survey.

  ## Examples

      iex> create_survey(%{field: value})
      {:ok, %Survey{}}

      iex> create_survey(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_survey(attrs \\ %{}) do
    result =
      %Survey{}
      |> Survey.changeset(attrs)
      |> Repo.insert()

    SurveyServer.poke()

    result
  end

  @doc """
  Updates a survey.

  ## Examples

      iex> update_survey(survey, %{field: new_value})
      {:ok, %Survey{}}

      iex> update_survey(survey, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_survey(%Survey{} = survey, attrs) do
    survey
    |> Survey.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Survey.

  ## Examples

      iex> delete_survey(survey)
      {:ok, %Survey{}}

      iex> delete_survey(survey)
      {:error, %Ecto.Changeset{}}

  """
  def delete_survey(%Survey{} = survey) do
    Repo.delete(survey)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking survey changes.

  ## Examples

      iex> change_survey(survey)
      %Ecto.Changeset{source: %Survey{}}

  """
  def change_survey(%Survey{} = survey) do
    Survey.changeset(survey, %{})
  end

  def get_survey_by_slug(slug) do
    from(s in "surveys", where: [slug: ^slug], select: s.id)
    |> Repo.one()
  end

  @static_headers ~w(moniker feedback learning condition in_time out_time)a

  def write_survey(id) do
    filename =
      [static_path(), get_survey!(id).slug <> ".csv"]
      |> Path.join()

    file = File.open!(filename, [:write, :utf8])

    images =
      list_images()
      |> Enum.map(&Map.take(&1, [:origin_id, :id]))
      |> Enum.reduce(%{}, fn %{origin_id: oid, id: id}, acc ->
        Map.put(acc, id, oid)
      end)

    users =
      from(u in User, select: u, where: [survey_id: ^id], preload: [:answers])
      |> Repo.all()
      |> Enum.map(&Map.take(&1, [:answers, :moniker, :condition]))
      |> Enum.map(&map_user_values(&1, images))

    users
    |> CSV.encode(headers: @static_headers ++ Map.values(images))
    |> Enum.each(&IO.write(file, &1))

    filename
  end

  defp map_user_values(%{answers: answers, condition: condition} = user, images) do
    {in_time, out_time} = get_times_from_answers(answers)

    Enum.reduce(answers, user, fn %{image_id: iid, correct: cor?}, acc ->
      Map.put(acc, images[iid], cor?)
    end)
    |> Map.delete(:answers)
    |> Map.put(:condition, condition)
    |> Map.put(:feedback, condition |> Condition.feedback() |> to_string())
    |> Map.put(:learning, condition |> Condition.learning() |> to_string())
    |> Map.put(:in_time, in_time)
    |> Map.put(:out_time, out_time)
  end

  defp get_times_from_answers(answers) do
    sorted_times =
      answers
      |> Enum.map(& &1.inserted_at)
      |> Enum.sort(&(NaiveDateTime.compare(&1, &2) != :gt))

    {List.first(sorted_times), List.last(sorted_times)}
  end

  @doc """
  Returns the list of answers.

  ## Examples

      iex> list_answers()
      [%Answer{}, ...]

  """
  def list_answers do
    Repo.all(Answer)
  end

  @doc """
  Gets a single answer.

  Raises `Ecto.NoResultsError` if the Answer does not exist.

  ## Examples

      iex> get_answer!(123)
      %Answer{}

      iex> get_answer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_answer!(id), do: Repo.get!(Answer, id)

  @doc """
  Creates a answer.

  ## Examples

      iex> create_answer(%{field: value})
      {:ok, %Answer{}}

      iex> create_answer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_answer(attrs \\ %{}) do
    %Answer{}
    |> Answer.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a answer.

  ## Examples

      iex> update_answer(answer, %{field: new_value})
      {:ok, %Answer{}}

      iex> update_answer(answer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_answer(%Answer{} = answer, attrs) do
    answer
    |> Answer.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Answer.

  ## Examples

      iex> delete_answer(answer)
      {:ok, %Answer{}}

      iex> delete_answer(answer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_answer(%Answer{} = answer) do
    Repo.delete(answer)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking answer changes.

  ## Examples

      iex> change_answer(answer)
      %Ecto.Changeset{source: %Answer{}}

  """
  def change_answer(%Answer{} = answer) do
    Answer.changeset(answer, %{})
  end

  def save_answers(gameplay, user) do
    gameplay.played
    |> Enum.map(fn %{id: id, correct?: correct?, time_spent: time} ->
      %{user_id: user.id, correct: correct?, image_id: id, time_spent: time}
    end)
    |> Enum.each(&insert_or_update_answer/1)
  end

  private do
    defp insert_or_update_answer(%{user_id: uid, image_id: iid} = attrs) do
      q = from(a in Answer, select: a, where: [user_id: ^uid, image_id: ^iid])

      case Repo.one(q) do
        nil -> struct(Answer, attrs)
        ans -> ans
      end
      |> Answer.changeset(attrs)
      |> Repo.insert_or_update()
    end

    defp static_path, do: Path.join(["#{:code.priv_dir(:mole)}", "static"])
  end
end
