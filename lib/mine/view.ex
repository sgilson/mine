defmodule Mine.View do
  use Agent
  @moduledoc false

  # Struct

  @type alias_map :: %{Mine.key() => Mine.Alias.t()}
  @type ignored_fields :: %{Mine.key() => boolean}
  @type additional_fields :: %{Mine.key() => any}
  @type struct_aliases :: %{optional(atom) => Mine.Alias.t()}
  @type t :: %__MODULE__{
          name: Mine.key(),
          struct_aliases: struct_aliases,
          aliases: alias_map,
          additional: additional_fields,
          ignored: ignored_fields
        }
  defstruct [:name, :struct_aliases, aliases: %{}, additional: %{}, ignored: %{}]

  defp put_alias(struct = %__MODULE__{aliases: aliases}, key, alias_struct) do
    Map.replace!(struct, :aliases, Map.put(aliases, key, alias_struct))
  end

  defp put_field(struct = %__MODULE__{additional: additional}, key, value) do
    Map.replace!(struct, :additional, Map.put(additional, key, value))
  end

  defp put_ignored(struct = %__MODULE__{ignored: ignored}, key) do
    Map.replace!(struct, :ignored, Map.put(ignored, key, true))
  end

  # Client

  def start_link(module, view_name, opts) do
    state_fn = fn -> %__MODULE__{name: view_name, struct_aliases: struct_aliases(module)} end

    Agent.start_link(state_fn, opts)
  end

  def add_alias_field(pid, key, alias_struct = %Mine.Alias{}) do
    with :ok <- Agent.get(pid, &check_key(&1, key)) do
      Agent.update(pid, &put_alias(&1, key, alias_struct))
    end
  end

  def add_additional_field(pid, key, value) do
    with :ok <- Agent.get(pid, &check_key(&1, key, false)) do
      Agent.update(pid, &put_field(&1, key, value))
    end
  end

  def add_ignored_field(pid, key) do
    with :ok <- Agent.get(pid, &check_key(&1, key)) do
      Agent.update(pid, &put_ignored(&1, key))
    end
  end

  def get_state(pid) do
    Agent.get(pid, & &1)
  end

  def compose(pid) do
    %__MODULE__{
      struct_aliases: struct_aliases,
      aliases: aliases,
      additional: additional,
      ignored: ignored
    } = get_state(pid)

    struct_aliases
    |> Map.merge(aliases, &Mine.Alias.merge/3)
    |> Map.merge(additional)
    |> Map.drop(Map.keys(ignored))
    |> Enum.into(%{})
  end

  def stop(pid) do
    Agent.stop(pid)
  end

  # Server

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
    |> Enum.map(fn {k, v} -> {k, Mine.Alias.new(Atom.to_string(k), v)} end)
    |> Enum.into(%{})
  end
end
