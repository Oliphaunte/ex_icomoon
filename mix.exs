defmodule ExIcomoon.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_icomoon,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "ExIcomoon",
      source_url: "https://github.com/Oliphaunte/ex_icomoon",
      docs: [
        # The main page in the docs
        main: "ExIcomoon",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description() do
    "This package provides a liveview icon implementation that you can use with icomoon"
  end

  defp package do
    %{
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/Oliphaunte/ex_icomoon"}
    }
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix_html, "~> 3.2"},
      {:phoenix_live_view, "~> 0.17", optional: true},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
    ]
  end
end
