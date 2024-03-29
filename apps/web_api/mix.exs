defmodule AC.WebApi.MixProject do
  use Mix.Project

  def project do
    [
      app: :ac_web_api,
      version: "0.1.0",
      elixir: "~> 1.12",
      elixirc_paths: _elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        bless: :test
      ],
      dialyzer: [
        plt_add_deps: :apps_direct,
        plt_add_apps: [:ecto, :ex_unit, :mix, :phoenix_pubsub, :phoenix_view, :plug]
      ],
      name: "AC WebApi",
      aliases: _aliases(),
      deps: _deps()
    ]
  end

  def application do
    [
      mod: {AC.WebApi.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp _elixirc_paths(:test), do: ["lib", "test/support"]
  defp _elixirc_paths(_), do: ["lib"]

  defp _aliases do
    [
      bless: [&_bless/1]
    ]
  end

  defp _deps do
    [
      {:phoenix, "~> 1.6.5"},
      {:ecto, "~> 3.6"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      {:elixir_uuid, "~> 1.2"},

      # test dependencies
      {:dialyxir, "~> 1.0", runtime: false},
      {:excoveralls, "~> 0.10", only: :test},
      {:faker, "~> 0.17", only: [:test, :dev]},
      {:mox, "~> 1.0", only: :test}
    ]
  end

  defp _bless(_) do
    [
      {"compile", ["--warnings-as-errors", "--force"]},
      {"format", ["--check-formatted"]},
      {"coveralls.html", []},
      {"dialyzer", []}
    ]
    |> Enum.each(fn {task, args} ->
      IO.ANSI.format([:blue, "Running #{task} with args #{inspect(args)}"])
      |> IO.puts()

      Mix.Task.run(task, args)
    end)
  end
end
