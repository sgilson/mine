defmodule Mine.View do
  @moduledoc false

  alias Mine.Alias

  @type struct_aliases :: %{optional(atom) => Alias.t()}
  @type alias_map :: %{Mine.key() => Alias.t()}
  @type additional_fields :: %{Mine.key() => any}
  @type ignored_fields :: %{Mine.key() => boolean}
  @type t :: %__MODULE__{
          name: Mine.key(),
          struct_aliases: struct_aliases,
          aliases: alias_map,
          additional: additional_fields,
          ignored: ignored_fields
        }
  defstruct [:name, :struct_aliases, aliases: %{}, additional: %{}, ignored: %{}]

  def new(module, view_name) do
    %__MODULE__{name: view_name, struct_aliases: struct_aliases(module)}
  end

  def add_alias_field(view = %__MODULE__{}, key, alias_struct = %Alias{}) do
    with :ok <- check_key(view, key),
         :ok <- Alias.validate(alias_struct) do
      {:ok, put_alias(view, key, alias_struct)}
    end
  end

  def add_additional_field(view = %__MODULE__{}, key, value) do
    with :ok <- check_key(view, key, false) do
      {:ok, put_field(view, key, value)}
    end
  end

  def add_ignored_field(view = %__MODULE__{}, key) do
    with :ok <- check_key(view, key) do
      {:ok, put_ignored(view, key)}
    end
  end

  def compose(view) do
    %__MODULE__{
      struct_aliases: struct_aliases,
      aliases: aliases,
      additional: additional,
      ignored: ignored
    } = view

    struct_aliases
    |> Map.merge(aliases, &Alias.merge/3)
    |> Map.merge(additional)
    |> Map.drop(Map.keys(ignored))
    |> Enum.into(%{})
  end

  defp check_key(view, key, enforce_in_struct \\ true) do
    %__MODULE__{
      struct_aliases: struct_aliases,
      aliases: aliases,
      additional: additional,
      ignored: ignored
    } = view

    cond do
      Map.has_key?(aliases, key) -> {:error, :duplicate}
      Map.has_key?(additional, key) -> {:error, :duplicate}
      Map.has_key?(ignored, key) -> {:error, :duplicate}
      enforce_in_struct && not Map.has_key?(struct_aliases, key) -> {:error, :not_found}
      true -> :ok
    end
  end

  defp struct_aliases(mod) do
    Module.get_attribute(mod, :struct)
    |> Map.from_struct()
    |> Enum.map(fn {k, v} -> {k, Alias.new(Atom.to_string(k), v)} end)
    |> Enum.into(%{})
  end

  defp put_alias(struct = %__MODULE__{aliases: aliases}, key, alias_struct) do
    Map.replace!(struct, :aliases, Map.put(aliases, key, alias_struct))
  end

  defp put_field(struct = %__MODULE__{additional: additional}, key, value) do
    Map.replace!(struct, :additional, Map.put(additional, key, value))
  end

  defp put_ignored(struct = %__MODULE__{ignored: ignored}, key) do
    Map.replace!(struct, :ignored, Map.put(ignored, key, true))
  end
end
