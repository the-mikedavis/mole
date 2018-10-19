use Mix.Config

config :mole, MoleWeb.Endpoint,
  http: [port: 4001],
  server: false

config :logger, level: :warn

config :mole,
  http_client: HTTPoisonMock,
  auto_start: false

config :mole, Mole.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "mole_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
