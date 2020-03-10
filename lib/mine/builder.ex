defmodule Mine.Builder do
  alias Mine.Alias

  import Macro, only: [var: 2]
  import Enum, only: [map: 2, filter: 2]

  @moduledoc false

  # building to_view

  def build_to_view(module, view_name, view) do
    quote do
      def to_view(
            %unquote(module){unquote_splicing(match_aliased_keys(module, view))},
            unquote(view_name)
          ) do
        %{unquote_splicing(build_map_body_ast(module, view))}
      end
    end
  end

  defp match_aliased_keys(module, map) when is_map(map) do
    map
    |> filter(&val_is_alias?/1)
    |> map(&elem(&1, 0))
    |> map(fn k -> quote(do: {unquote(k), unquote(var(k, module))}) end)
  end

  defp build_map_body_ast(module, view) do
    map(view, fn
      {old_key, %Alias{as: as, default: default, map_to: map_to}} ->
        {
          as,
          access_struct(module, old_key, default)
          |> conditionally_wrap(map_to)
        }

      kv ->
        kv
    end)
  end

  defp access_struct(module, var_name, default) do
    if is_nil(default) do
      quote(do: unquote(var(var_name, module)))
    else
      quote do
        if is_nil(unquote(var(var_name, module))) do
          unquote(default)
        else
          unquote(var(var_name, module))
        end
      end
    end
  end

  # building from_view

  def build_from_view(module, view_name, view) do
    quote do
      def from_view(unquote(var(:source, module)), unquote(view_name)) do
        %unquote(module){unquote_splicing(access_aliased_keys(module, view))}
      end
    end
  end

  defp access_aliased_keys(module, map) when is_map(map) do
    map
    |> filter(&val_is_alias?/1)
    |> map(&construct_access(module, &1))
  end

  defp construct_access(module, {key, alias}) do
    get_from_arguments =
      quote(
        do:
          Map.get(
            unquote(var(:source, module)),
            unquote(alias.as),
            unquote(alias.default)
          )
      )
      |> conditionally_wrap(alias.map_from)

    quote(do: {unquote(key), unquote(get_from_arguments)})
  end

  # helpers

  defp conditionally_wrap(expr, nil), do: expr

  defp conditionally_wrap(expr, fun) do
    quote do
      unquote(fun).(unquote(expr))
    end
  end

  defp val_is_alias?({_, %Mine.Alias{}}), do: true
  defp val_is_alias?(_), do: false
end
