defmodule MoleWeb.UserView do
  use MoleWeb, :view

  alias Mole.Accounts.User

  def first_name(%User{name: name}) do
    name
    |> String.split(" ")
    |> Enum.at(0)
  end
end
