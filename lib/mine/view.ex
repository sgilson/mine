defmodule Mine.View do
  defstruct [:aliases, :additional_fields]

  def new(aliases, additional), do: %__MODULE__{aliases: aliases, additional_fields: additional}
end
