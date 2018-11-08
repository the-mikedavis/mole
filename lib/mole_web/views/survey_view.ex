defmodule MoleWeb.SurveyView do
  use MoleWeb, :view

  alias Mole.Content.Condition

  def condition(%{condition: con}), do: Condition.to_string(con)

  def force_options do
    0..5
    |> Enum.map(&Condition.to_string/1)
    |> Enum.with_index()
  end
end
