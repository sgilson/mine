defmodule PortBase do
  defstruct [:num, :enabled]

  def to_view(%PortBase{num: num, enabled: enabled}) do
    %{
      "$" => num,
      "@enabled" => enabled
    }
  end

  def from_view(source) do
    %PortBase{num: Map.get(source, "$", 3000), enabled: Map.get(source, "@enabled")}
  end
end

defmodule PortMine do
  use Mine

  defstruct [:num, :enabled]

  defview do
    alias_field :num, as: "$", default: 3000
    alias_field :enabled, "@enabled"
  end
end

to_view_jobs = %{
  "Base" => &PortBase.to_view(struct(PortBase, &1)),
  "Mine" => &PortMine.to_view(struct(PortMine, &1))
}

to_view_data = %{
  "empty" => [],
  "expected" => [num: 4000, enabled: true]
}

from_view_jobs = %{
  "Base" => &PortBase.from_view/1,
  "Mine" => &PortMine.from_view/1
}

from_view_data = %{
  "empty map" => %{},
  "expected" => %{"$" => 2000, "@enabled" => false}
}


Benchee.run(to_view_jobs, inputs: to_view_data)
Benchee.run(from_view_jobs, inputs: from_view_data)