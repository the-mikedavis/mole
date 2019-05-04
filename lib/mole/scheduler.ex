defmodule Mole.Scheduler do
  use Quantum.Scheduler,
    otp_app: :mole

  @moduledoc """
  Scheduler for scavenging the database
  """
end
