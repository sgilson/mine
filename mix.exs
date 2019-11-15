defmodule Proto.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :mine,
      version: @version,
      elixir: "~> 1.9",
      deps: deps(),
      package: package(),
      description: description(),
      docs: docs(),
      source_url: "https://github.com/sgilson/mine",
      name: "Mine",
      test_coverage: [
        tool: ExCoveralls
      ],
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:excoveralls, "~> 0.12.0", only: :test},
      {:ex_doc, "~> 0.19", only: [:dev, :test]},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false}
    ]
  end

  def package do
    [
      name: :mine,
      licenses: ["MIT"],
      maintainers: ["Spencer Gilson"],
      links: %{"GitHub" => "https://github.com/sgilson/mine"}
    ]
  end

  def description do
    """
    Mine is a lightweight package for defining views for structs. It
    aims to eliminate the boilerplate required to write and maintain an
    anti-corruption layer between your structs and any external APIs you
    interface with.
    """
  end

  def docs do
    [
      source_ref: "v#{@version}",
      source_url: "https://github.com/sgilson/mine",
      main: "Mine",
      extras: ["README.md"]
    ]
  end

  defp elixirc_paths(:test), do: ["test/support", "lib"]
  defp elixirc_paths(_), do: ["lib"]
end
