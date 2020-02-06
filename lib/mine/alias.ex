defmodule Mine.Alias do
  @moduledoc """
  Stores the data associated with an aliased field. Composed at compile time
  and used during runtime to determine how a field should be translated.
  """

  import Mine.AstUtils

  @type t :: %__MODULE__{as: Mine.key(), default: any}
  defstruct [:as, :default, :map_to, :map_from]

  @doc "Creates a new `Mine.Alias` struct"
  @spec new(Mine.key(), any) :: t
  def new(as, default), do: %__MODULE__{as: as, default: default}

  @doc """
  Utility function for merging two `Mine.Alias` structs. Currently only returns
  the second struct.
  """
  @spec merge(any, t, t) :: t
  def merge(_key, _s1 = %__MODULE__{}, s2 = %__MODULE__{}), do: s2

  # map_to and map_from are still ASTs
  def validate(%__MODULE__{as: as, map_to: map_to, map_from: map_from}) do
    with :ok <- validate_key(as, :as),
         :ok <- validate_mapper(map_to),
         :ok <- validate_mapper(map_from),
         do: :ok
  end

  defp validate_key(name, usage) do
    if Mine.valid_key?(name), do: :ok, else: {:error, {:invalid_key, usage, name}}
  end

  defp validate_mapper(nil), do: :ok

  defp validate_mapper(ast) do
    cond do
      is_nil(ast) -> :ok
      ast_is_function?(ast) -> :ok
      true -> {:error, {:not_a_function, ast}}
    end
  end
end
