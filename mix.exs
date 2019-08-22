defmodule Nascent.MixProject do
  use Mix.Project

  def project do
    [
      app: :nascent,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Nascent.Application, []}
    ]
  end

  defp deps do
    [
      {:conduit, "~> 0.12.0"},
      {:elixir_nsq, "~> 1.1.0"},
      {:jason, "~> 1.1"},
      {:credo, "~> 1.1.0", only: [:dev, :test], runtime: false}
    ]
  end
end
