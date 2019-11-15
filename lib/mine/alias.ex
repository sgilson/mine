defmodule Mine.Alias do
  @moduledoc """
  Stores the data associated with an aliased field. Composed at compile time
  and used during runtime to determine how a field should be translated.
  """

  @type t :: %__MODULE__{as: Mine.key(), default: any}
  defstruct [:as, :default]

  @doc "Creates a new `Mine.Alias` struct"
  @spec new(Mine.key(), any) :: t
  def new(as, default), do: %__MODULE__{as: as, default: default}

  @doc """
  Utility function for merging two `Mine.Alias` structs. Currently only returns
  the second struct.
  """
  @spec merge(any, t, t) :: t
  def merge(_key, _s1 = %__MODULE__{}, s2 = %__MODULE__{}), do: s2
end
