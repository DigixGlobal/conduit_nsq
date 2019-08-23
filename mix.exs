defmodule ConduitNSQ.MixProject do
  use Mix.Project

  def project do
    [
      app: :conduit_nsq,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:conduit, "0.12.10"},
      {:elixir_nsq, "~> 1.1.0"},
      {:honeydew, "~> 1.4.4"},
      {:jason, "~> 1.1.0", optional: true},
      {:credo, "~> 1.1.0", only: [:dev, :test], runtime: false}
    ]
  end
end
