use Mix.Config

config :mole,
  min_amount: 1000,
  signing_token: "${MOLE_SIGNING_TOKEN}",
  default_password: "${MOLE_DEFAULT_PASSWORD}"

config :mole, Mole.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "${MOLE_DB_USERNAME}",
  password: "${MOLE_DB_PASSWORD}",
  database: "${MOLE_DB_DATABASE}",
  pool_size: 15

config :mole, MoleWeb.Endpoint,
  load_from_system_env: true,
  url: [host: "${MOLE_HOST}", port: "${MOLE_PORT}"],
  http: [port: "${MOLE_PORT}"],
  cache_static_manifest: "priv/static/cache_manifest.json",
  secret_key_base: "${MOLE_SECRET_KEYBASE}",
  root: ".",
  server: true

config :mole, Mole.Scheduler,
  jobs: [
    {"@daily", {Mole.Accounts, :cull_users, []}},
    {"@daily", {Mole.Accounts, :cull_high_scores, []}}
  ]

config :logger, level: :info
