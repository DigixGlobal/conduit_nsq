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
      {:elixir_nsq, "~> 1.1.0"}
    ]
  end
end
