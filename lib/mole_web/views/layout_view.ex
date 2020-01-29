defmodule MoleWeb.LayoutView do
  use MoleWeb, :view

  @spec feedback_time_msec() :: String.t()
  def feedback_time_msec do
    Application.get_env(:mole, :feedback_time_msec, "1000")
  end
end
