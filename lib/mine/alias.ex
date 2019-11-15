defmodule Mine.Alias do
  defstruct [:as, :default]

  def new(as, default), do: %__MODULE__{as: as, default: default}

  def merge(_key, _s1 = %{}, s2 = %{}), do: s2
end
