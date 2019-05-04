use Mix.Config

config :mole,
  ecto_repos: [Mole.Repo],
  http_client: HTTPoison,
  malignant_range: 35..40,
  min_amount: 200,
  auto_start: true,
  correct_mult: 3,
  incorrect_mult: 2,
  user_socket_secret: "aEv4XpOMzHrn/EWs/yYqMEiRG4D7SgSUt08mQyasbyUp6kNkJOAcTY9hhVcJmi7w",
  default_admins: ["the-mikedavis", "soyoonk", "nickc", "zhuangq"],
  default_password: "pleasechangethis",
  leaderboard_limit: 10

config :mole, MoleWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "IV0jX8QHymKlHxwrbZdV3o05C267MRG+M9VbLCzp5x4nXatSp6MFJM60+PY/4idP",
  render_errors: [view: MoleWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Mole.PubSub, adapter: Phoenix.PubSub.PG2]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason
config :ecto, :json_library, Jason

config :phoenix, :template_engines,
  slim: PhoenixSlime.Engine,
  slime: PhoenixSlime.Engine

import_config "#{Mix.env()}.exs"
