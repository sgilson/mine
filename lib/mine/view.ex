defmodule Mine.View do
  @moduledoc false

  alias Mine.Alias

  @type struct_aliases :: %{optional(atom) => Alias.t()}
  @type alias_map :: %{Mine.key() => Alias.t()}
  @type additional_fields :: %{Mine.key() => any}
  @type ignored_fields :: %{Mine.key() => boolean}
  @type exclude_if_fn :: nil | (any -> boolean)
  @type t :: %__MODULE__{
          name: Mine.key(),
          struct_aliases: struct_aliases,
          aliases: alias_map,
          additional: additional_fields,
          ignored: ignored_fields,
          exclude_if_fn: exclude_if_fn
        }
  defstruct [
    :name,
    :struct_aliases,
    aliases: %{},
    additional: %{},
    ignored: %{},
    exclude_if_fn: nil
  ]

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

  def set_exclude_if(view = %__MODULE__{}, exclude_if) do
    with {:ok, exclude_if} <- validate_exclude_if(exclude_if) do
      {:ok, %{view | exclude_if_fn: exclude_if}}
    end
  end

  def compose(view) do
    %__MODULE__{
      struct_aliases: struct_aliases,
      aliases: aliases,
      additional: additional,
      ignored: ignored
    } = view

    result =
      struct_aliases
      |> Map.merge(aliases, &Alias.merge/3)
      |> Map.merge(additional)
      |> Map.drop(Map.keys(ignored))
      |> Enum.into(%{})

    {result, view}
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

  defp validate_exclude_if(nil), do: {:ok, nil}
  defp validate_exclude_if(:is_nil), do: {:ok, &Mine.View.is_nil/1}
  defp validate_exclude_if(:is_blank), do: {:ok, &Mine.View.is_blank/1}

  defp validate_exclude_if(func) when is_function(func, 1) do
    try do
      Macro.escape(func)
    rescue
      _ in ArgumentError -> {:error, {:invalid_exclude_if, func}}
    end
  end

  defp validate_exclude_if(other), do: {:error, {:invalid_exclude_if, other}}

  @doc false
  def is_blank(nil), do: true
  def is_blank(""), do: true
  def is_blank(_), do: false

  @doc false
  def is_nil(nil), do: true
  def is_nil(_), do: false
end
