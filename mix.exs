defmodule Agogo.MixProject do
  use Mix.Project

  def project do
    [
      app: :agogo,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Agogo.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.0"},
      {:remote_ip, "~> 1.1"},
      {:cors_plug, "~> 3.0"},
      {:jason, "~> 1.1"},
      {:mongodb_driver, "~> 0.9.2"}
    ]
  end
end
