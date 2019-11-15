defmodule Mine.ViewDefinition do
  @moduledoc """
  Encapsulate the information required to turn a struct into it's corresponding
  view or vice versa.
  """

  @type alias_map :: %{Mine.key() => Mine.Alias.t()}
  @type additional_fields :: %{Mine.key() => any}
  @type t :: %__MODULE__{aliases: alias_map, additional_fields: additional_fields}
  defstruct [:aliases, :additional_fields]

  @spec new(alias_map, additional_fields) :: t
  @doc "Creates a new `Mine.ViewDefinition` struct."
  def new(aliases, additional), do: %__MODULE__{aliases: aliases, additional_fields: additional}
end
