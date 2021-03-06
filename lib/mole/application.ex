defmodule Mole.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Mole.Repo,
      MoleWeb.Endpoint,
      {Mole.GameplayServer, %{}},
      {Mole.Content.SurveyServer, %{}}
    ]

    opts = [strategy: :one_for_one, name: Mole.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    MoleWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
