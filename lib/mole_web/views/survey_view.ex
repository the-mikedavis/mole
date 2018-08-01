defmodule MoleWeb.SurveyView do
  use MoleWeb, :view

  def condition(%{condition: con}),
    do: Mole.Content.Condition.to_string(con)
end
