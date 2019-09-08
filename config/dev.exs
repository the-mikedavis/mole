use Mix.Config

config :mole, MoleWeb.Endpoint,
  http: [port: System.get_env("PORT") || 4004],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: Path.expand("../assets", __DIR__)
    ]
  ]

config :mole, MoleWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/mole_web/views/.*(ex)$},
      ~r{lib/mole_web/templates/.*(eex|slim|slime)$}
    ]
  ]

config :logger, :console, format: "[$level] $message\n"
config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime

config :mole, Mole.Repo,
  adapter: Ecto.Adapters.MySQL,
  username: "root",
  password: "password",
  database: "mole_dev",
  hostname: "localhost",
  pool_size: 10
