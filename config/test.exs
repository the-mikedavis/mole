use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :mole, MoleWeb.Endpoint,
  http: [port: 4001],
  http_client: HTTPoisonMock,
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :mole,
  auto_start: false

# Configure your database
config :mole, Mole.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "mole_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
