defmodule Mole.AccountsTest do
  use Mole.DataCase

  alias Mole.Accounts
  alias Mole.Accounts.User

  describe "accounts -> user" do
    @user_valid_attrs %{username: "some username", password: "some password"}
    @user_update_attrs %{
      username: "another username",
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
      assert user.username == "some username"
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

      assert gotten.username == "another username"
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
  end
end
