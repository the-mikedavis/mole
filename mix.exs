defmodule Mole.MixProject do
  use Mix.Project

  def project do
    [
      app: :mole,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.travis": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        bless: :test
      ],
      test_coverage: [tool: ExCoveralls]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Mole.Application, []},
      extra_applications: [
        :logger,
        :runtime_tools,
        :phoenix,
        :cowboy,
        :phoenix_ecto
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, github: "phoenixframework/phoenix", override: true},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:postgrex, "~> 0.13"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:cowboy, "~> 1.0"},
      {:phoenix_slime, "~> 0.12"},
      {:comeonin, "~> 4.1"},
      {:bcrypt_elixir, "~> 1.0"},
      {:httpoison, "~> 1.0"},
      {:csv, "~> 2.0.0"},
      {:observer_cli, "~> 1.3"},
      {:quantum, "~> 2.3"},
      {:timex, "~> 3.0"},
      {:plug_cowboy, "~> 1.0"},
      {:tzdata, "~> 0.5.21"},

      # test
      {:credo, "~> 0.9", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.9", only: :test},
      {:mox, "~> 0.3"},
      {:private, "~> 0.1.1"},

      # deploy
      {:distillery, github: "bitwalker/distillery"}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"],
      bless: [&bless/1]
    ]
  end

  defp bless(_) do
    [
      {"compile", ["--warnings-as-errors", "--force"]},
      {"coveralls.html", []},
      {"format", ["--check-formatted"]},
      {"credo", []}
    ]
    |> Enum.each(fn {task, args} ->
      [:cyan, "Running #{task} with args #{inspect(args)}"]
      |> IO.ANSI.format()
      |> IO.puts()

      Mix.Task.run(task, args)
    end)
  end
end
