defmodule ConduitNSQ.MixProject do
  use Mix.Project

  def project do
    [
      app: :conduit_nsq,
      version: "0.1.1",
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      name: "ConduitNQS",
      source_url: "https://github.com/DigixGlobal/conduit_nsq",
      homepage_url: "https://hexdocs.pm/conduit_nsq",
      docs: docs(),
      test_coverage: [
        tool: Coverex.Task,
        coveralls: true
      ],
      preferred_cli_env: [espec: :test],
      description: "NSQ adapter for Conduit.",
      package: package()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "spec"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:elixir_nsq, "~> 1.1.0"},
      {:honeydew, "~> 1.4.4"},
      {:jason, "~> 1.1.0"},
      {:conduit, "0.12.10"},
      {:coverex, "~> 1.4.10", only: :test},
      {:credo, "~> 1.1.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false},
      {:espec, "~> 1.7.0", only: :test},
      {:quixir, "~> 0.9", only: :test}
    ]
  end

  defp aliases do
    [
      test: "espec"
    ]
  end

  defp package do
    [
      name: :conduit_nsq,
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Francis Murillo"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/DigixGlobal/conduit_nsq",
        "Docs" => "https://hexdocs.pm/conduit_nsq"
      }
    ]
  end

  defp docs do
    [
      main: "readme",
      project: "ConduitNSQ",
      extra_section: "Guides",
      extras: ["README.md"],
      assets: ["assets"]
    ]
  end
end
