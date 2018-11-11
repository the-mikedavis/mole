defmodule Mole.AccountsTest do
  use Mole.DataCase, async: true

  alias Mole.{Accounts, Accounts.User, Content, Repo}

  describe "accounts -> user" do
    @user_valid_attrs %{username: "someusername", password: "some password"}
    @user_update_attrs %{
      username: "anotherusername",
      password: "another password"
    }
    @user_invalid_attrs %{username: "", password: ""}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@user_valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      [%User{id: id}] = Accounts.list_users()
      assert user.id == id
    end

    test "get_user/1 returns the user with given id" do
      user = user_fixture()

      gotten = Accounts.get_user(user.id)

      assert user.id == gotten.id
      assert user.username == gotten.username
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()

      gotten_user = Accounts.get_user!(user.id)

      assert gotten_user.id == user.id
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@user_valid_attrs)
      assert user.username == "someusername"
      assert user.password == "some password"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_user(@user_invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      id = user.id

      assert {:ok, %User{id: ^id} = gotten} =
               Accounts.update_user(user, @user_update_attrs)

      assert gotten.username == "anotherusername"
      assert gotten.password == "another password"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Accounts.update_user(user, @user_invalid_attrs)

      assert user.id == Accounts.get_user!(user.id).id
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end

    test "trying to create a user with a duped username -> changeset error" do
      user = user_fixture()

      assert {:error, changeset} =
               %{username: user.username}
               |> Enum.into(@user_valid_attrs)
               |> Accounts.create_user()

      assert [username: {"has already been taken", []}] == changeset.errors
    end

    test "creating a non-alphanumeric username gives changeset errors" do
      assert {:error, changeset} =
               %{username: "I have a space"}
               |> Enum.into(@user_valid_attrs)
               |> Accounts.create_user()
    end

    test "basic usernames work" do
      [
        "the-mikedavis",
        "shakate",
        "nickc"
      ]
      |> Enum.each(fn uname ->
        assert %User{} = user_fixture(%{username: uname})
      end)
    end

    test "weird usernames fail" do
      [
        "the mikedavis",
        "$hakate",
        "nick+c",
        "====="
      ]
      |> Enum.each(fn uname ->
        assert_raise MatchError, fn ->
          %User{} = user_fixture(%{username: uname})
        end
      end)
    end
  end

  describe "users & surveys are bound together" do
    @survey_valid_attrs %{
      slug: "qualtrics",
      prelink: "prequal",
      postlink: "postqual"
    }

    def survey_fixture(attrs \\ %{}) do
      {:ok, survey} =
        attrs
        |> Enum.into(@survey_valid_attrs)
        |> Content.create_survey()

      Repo.preload(survey, :users)
    end

    test "to get all users in a survey" do
      survey = survey_fixture()
      user1 = user_fixture(%{survey_id: survey.id})

      user2 =
        user_fixture(%{
          username: "other",
          password: "others",
          survey_id: survey.id
        })

      [gotten1, gotten2] = Accounts.get_users_by_survey(survey)
      assert gotten1.id == user1.id
      assert gotten2.id == user2.id
    end
  end

  describe "authentication matters" do
    test "authenticating by uname & pass" do
      user = user_fixture()

      {:ok, gotten} =
        Accounts.authenticate_by_uname_and_pass(
          "someusername",
          "some password"
        )

      assert gotten.id == user.id
    end

    test "authenticating by uname & wrong pass" do
      _user = user_fixture()

      assert Accounts.authenticate_by_uname_and_pass(
               "someusername",
               "another password"
             ) == {:error, :unauthorized}
    end

    test "authenticating by wrong uname & wrong pass" do
      _user = user_fixture()

      assert Accounts.authenticate_by_uname_and_pass(
               "anotherusername",
               "another password"
             ) == {:error, :not_found}
    end
  end

  describe "utility functions of accounts" do
    test "username_taken?" do
      user = user_fixture()
      assert Accounts.username_taken?(user.username)
      assert not Accounts.username_taken?("anotherusername")
    end
  end
end
