defmodule Mine.ViewDefinition do
  @moduledoc """
  Encapsulate the information required to turn a struct into it's corresponding
  view or vice versa.
  """

  @typedoc "Key value pair used to expand a view"
  @type additional_field :: {String.t(), any}
  @type t :: %__MODULE__{aliases: [Mine.Alias.t()], additional_fields: [additional_field]}
  defstruct [:aliases, :additional_fields]

  @spec new(%{Mine.key() => Mine.Alias.t()}, [additional_field]) :: t
  @doc "Creates a new `Mine.View` struct."
  def new(aliases, additional), do: %__MODULE__{aliases: aliases, additional_fields: additional}
end
