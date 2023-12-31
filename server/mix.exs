defmodule Berkeley.MixProject do
  use Mix.Project

  def project do
    [
      app: :berkeley,
      version: "0.1.0",
      elixir: "~> 1.15.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Berkeley.Application, []},
      extra_applications: [:logger, :runtime_tools, :inets]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/*"]
  defp elixirc_paths(_), do: ["lib", "web"]

  # Specifies your project dependencies.
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.7.7"},
      {:phoenix_view, "~> 2.0"},
      {:phoenix_ecto, "~> 4.4.2"},
      {:ecto_sql, "~> 3.10.1"},
      {:postgrex, "~> 0.17.2"},
      {:assent, "~> 0.2.1"},
      {:telemetry_metrics, "~> 0.4.0"},
      {:telemetry_poller, "~> 0.4.0"},
      {:styler, "~> 0.8.1", only: [:dev, :test], runtime: false},
      {:jason, "~> 1.4.0"},
      {:cors_plug, "~> 3.0.3"},
      {:pbkdf2_elixir, "~> 2.0.0"},
      {:plug_cowboy, "~> 2.6.1"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup", "run -e \"Berkeley.Seed.run\""],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
