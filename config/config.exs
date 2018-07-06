# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :mole,
  ecto_repos: [Mole.Repo],
  http_client: HTTPoison,
  malignant_range: 35..40,
  min_amount: 200,
  auto_start: true,
  correct_mult: 3,
  incorrect_mult: 2

# Configures the endpoint
config :mole, MoleWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base:
    "IV0jX8QHymKlHxwrbZdV3o05C267MRG+M9VbLCzp5x4nXatSp6MFJM60+PY/4idP",
  render_errors: [view: MoleWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Mole.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix and Ecto
config :phoenix, :json_library, Jason
config :ecto, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

config :phoenix, :template_engines,
  slim: PhoenixSlime.Engine,
  slime: PhoenixSlime.Engine
