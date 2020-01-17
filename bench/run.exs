defmodule Port.ElixirSingleView do
  defstruct [:num, :enabled]

  def to_view(%Port.ElixirSingleView{num: num, enabled: enabled}) do
    %{
      "$" => num,
      "@enabled" => enabled
    }
  end

  def from_view(source) do
    %Port.ElixirSingleView{num: Map.get(source, "$", 3000), enabled: Map.get(source, "@enabled")}
  end
end

defmodule Port.ElixirMultipleViews do
  defstruct [:num, :enabled]

  def to_view(struct, view \\ :default)
  def to_view(%Port.ElixirMultipleViews{num: num, enabled: enabled}, :default) do
    %{
      "$" => num,
      "@enabled" => enabled
    }
  end
  def to_view(_, _), do: nil

  def from_view(source, view \\ :default)
  def from_view(source, :default) do
    %Port.ElixirMultipleViews{num: Map.get(source, "$", 3000), enabled: Map.get(source, "@enabled")}
  end
  def from_view(_, _), do: nil
end

defmodule Port.Mine do
  use Mine

  defstruct [:num, :enabled]

  defview do
    alias_field :num, as: "$", default: 3000
    alias_field :enabled, "@enabled"
  end
end

defmodule Mine.BenchmarkRunner do

  @time 2
  @memory_time 2

  defp out_file(name) do
    "bench/out/#{name}_#{Mine.MixProject.get_version()}_report.md"
  end

  defp run_test(title, functions, inputs) do
    Benchee.run(
      functions,
      inputs: inputs,
      title: "Benchmark - #{title}",
      time: @time,
      memory_time: @memory_time,
      formatters: [{Benchee.Formatters.Markdown, file: out_file(title)}]
    )
  end

  def run_all do
    run_test(
      "to_view",
      %{
        "Elixir - Functions with Arity 1" => &Port.ElixirSingleView.to_view(struct(Port.ElixirSingleView, &1)),
        "Elixir - Functions with Arity >1" => &Port.ElixirMultipleViews.to_view(struct(Port.ElixirMultipleViews, &1)),
        "Mine" => &Port.Mine.to_view(struct(Port.Mine, &1))
      },
      %{
        "empty" => [],
        "expected" => [
          num: 4000,
          enabled: true
        ]
      }
    )
    run_test(
      "from_view",
      %{
        "Elixir - Functions with Arity 1" => &Port.ElixirSingleView.from_view/1,
        "Elixir - Functions with Arity >1" => &Port.ElixirMultipleViews.from_view/1,
        "Mine" => &Port.Mine.from_view/1
      },
      %{
        "empty map" => %{},
        "expected" => %{
          "$" => 2000,
          "@enabled" => false
        }
      }
    )
  end
end

Mine.BenchmarkRunner.run_all()