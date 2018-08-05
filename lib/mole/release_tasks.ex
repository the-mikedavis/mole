defmodule Mole.ReleaseTasks do
  @moduledoc false

  @start_apps [
    :postgrex,
    :ecto
  ]

  def app, do: :mole

  def repos, do: [Mole.Repo]

  def migrate do
    me = app()

    IO.puts("Loading #{me}...")
    Application.load(me)

    IO.puts("Starting dependencies...")
    Enum.each(@start_apps, &Application.ensure_all_started/1)

    IO.puts("Starting repos...")
    Enum.each(repos(), & &1.start_link(pool_size: 1))

    run_migrations()

    IO.puts("Success!")
    :init.stop()
  end

  def run_migrations, do: Enum.each(repos(), &run_migrations_for/1)

  def priv_dir(app), do: "#{:code.priv_dir(app)}"

  defp run_migrations_for(repo) do
    app = Keyword.get(repo.config, :otp_app)
    IO.puts("Running migrations for #{app}")
    Ecto.Migrator.run(repo, migrations_path(repo), :up, all: true)
  end

  def migrations_path(repo), do: priv_path_for(repo, "migrations")

  def priv_path_for(repo, filename) do
    app = Keyword.get(repo.config, :otp_app)

    repo_underscore =
      repo |> Module.split() |> List.last() |> Macro.underscore()

    Path.join([priv_dir(app), repo_underscore, filename])
  end
end
