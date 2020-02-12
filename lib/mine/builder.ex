defmodule Mine.Builder do
  alias Mine.Alias

  @moduledoc false

  def build_to_view(module, view_name, view) do
    map_body_ast =
      view
      |> Enum.map(fn
        {old, %Alias{as: as, default: default, map_to: map_to}} ->
          {
            as,
            access_struct(old, default)
            |> conditionally_wrap(map_to)
          }

        kv ->
          kv
      end)

    quote do
      def to_view(
            %unquote(module){unquote_splicing(match_aliased_keys(view))},
            unquote(view_name)
          ) do
        %{unquote_splicing(map_body_ast)}
      end
    end
  end

  def build_from_view(module, view_name, view) do
    quote do
      def from_view(unquote(Macro.var(:source, nil)), unquote(view_name)) do
        %unquote(module){unquote_splicing(access_aliased_keys(view))}
      end
    end
  end

  defp access_struct(var_name, default) do
    if is_nil(default) do
      quote(do: unquote(Macro.var(var_name, nil)))
    else
      quote do
        if is_nil(unquote(Macro.var(var_name, nil))) do
          unquote(default)
        else
          unquote(Macro.var(var_name, nil))
        end
      end
    end
  end

  defp match_aliased_keys(map) when is_map(map) do
    map
    |> Enum.filter(&val_is_alias?/1)
    |> Enum.map(&elem(&1, 0))
    |> Enum.map(fn k ->
      quote(do: {unquote(k), unquote(Macro.var(k, nil))})
    end)
  end

  defp access_aliased_keys(map) when is_map(map) do
    map
    |> Enum.filter(&val_is_alias?/1)
    |> Enum.map(&construct_access/1)
  end

  defp construct_access({key, alias}) do
    get_using_map =
      quote(
        do:
          Map.get(
            unquote(Macro.var(:source, nil)),
            unquote(alias.as),
            unquote(alias.default)
          )
      )
      |> conditionally_wrap(alias.map_from)

    quote(do: {unquote(key), unquote(get_using_map)})
  end

  defp conditionally_wrap(expr, nil), do: expr

  defp conditionally_wrap(expr, fun) do
    quote do
      unquote(fun).(unquote(expr))
    end
  end

  defp val_is_alias?({_, %Mine.Alias{}}), do: true
  defp val_is_alias?(_), do: false
end
