defmodule Mine.MixProject do
  use Mix.Project

  @version "0.2.0"
  def get_version, do: @version

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
      elixirc_paths: ["lib"]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:excoveralls, "~> 0.12.0", only: :test},
      {:ex_doc, "~> 0.21.2", only: [:dev, :test]},
      {:benchee, "~> 1.0.1", only: :bench},
      {:benchee_markdown, "~> 0.2.3", only: :bench}
    ]
  end

  def package do
    [
      name: :mine,
      licenses: ["MIT"],
      maintainers: ["Spencer Gilson"],
      links: %{
        "GitHub" => "https://github.com/sgilson/mine"
      }
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
      source_url: "https://github.com/sgilson/mine",
      main: "readme",
      extras: ["README.md"] ++ benchmark_results(),
      groups_for_extras: [
        Benchmarks: ~r(bench/out)
      ]
    ]
  end

  defp benchmark_results, do: Path.wildcard("bench/out/*.md")
end
