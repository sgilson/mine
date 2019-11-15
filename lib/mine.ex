defmodule Mine do
  defmacro __using__(_) do
    quote do
      import Mine

      @mine false
      @mine_builds %{}
      @mine_default_view :default

      Module.register_attribute(__MODULE__, :mine_name, accumulate: false)
      Module.register_attribute(__MODULE__, :mine_names, accumulate: true)
      Module.register_attribute(__MODULE__, :mine_aliases, accumulate: true)
      Module.register_attribute(__MODULE__, :mine_additional_fields, accumulate: true)
      Module.register_attribute(__MODULE__, :mine_ignored, accumulate: true)

      @after_compile Mine

      def to_view(struct, name \\ __MODULE__.__mine__(:default_view))
      def normalize(source, name \\ __MODULE__.__mine__(:default_view))
      def from_view(source, name \\ __MODULE__.__mine__(:default_view))
      def from_view!(source, name \\ __MODULE__.__mine__(:default_view))

      def from_view!(source, name) do
        case from_view(source, name) do
          {:ok, res} -> res
          {:error, reason} -> raise(reason)
        end
      end

      def validate(struct) do
        {:ok, struct}
      end

      def new_instance(source) do
        {:ok, struct(__MODULE__, source)}
      end

      defoverridable validate: 1, new_instance: 1
    end
  end

  defmacro defview(name \\ :default, do: body) do
    prelude =
      quote do
        if not valid_key?(unquote(name)) do
          raise Mine.View.CompileError,
            module: __MODULE__,
            view: unquote(name),
            message: """
            not a valid view name

            Acceptable types are: Atom, Binary
            """
        end

        unless has_struct?(__MODULE__) do
          raise Mine.View.CompileError,
            module: __MODULE__,
            view: unquote(name),
            message: """
            must define a struct to use #{inspect(Mine)}

            Make sure #{inspect(__MODULE__)} uses defstruct/1 before defview.
            """
        end

        Mine.__activate_name__(__MODULE__, unquote(name))
      end

    postlude =
      quote bind_quoted: [name: name], unquote: false do
        view = Mine.__build_view__(__MODULE__, name)
        Mine.__save_view__(__MODULE__, name, view)

        aliases = @mine_aliases |> Enum.reverse()
        ignored = @mine_ignored |> Enum.reverse()
        additional = @mine_additional_fields |> Enum.reverse()
        builds = @mine_builds
        default = @mine_default_view
        names = @mine_names |> Enum.reverse()

        def __mine__(:aliases), do: unquote(Macro.escape(aliases))
        def __mine__(:ignored), do: unquote(ignored)
        def __mine__(:additional), do: unquote(additional)
        def __mine__(:views), do: unquote(Macro.escape(builds))
        def __mine__(:default_view), do: unquote(default)
        def __mine__(:names), do: unquote(names)

        for {v, build} <- builds do
          def __mine__({:view, unquote(v)}), do: unquote(Macro.escape(build))
        end

        def to_view(struct = %__MODULE__{}, unquote(name)) do
          view = __MODULE__.__mine__(:views)[unquote(name)]

          mapped =
            for {key, %{as: as, default: def}} <- view.aliases, into: %{} do
              case Map.get(struct, key) do
                nil -> {as, def}
                other -> {as, other}
              end
            end

          Map.merge(mapped, view.additional_fields)
        end

        def normalize(source, unquote(name)) when is_map(source) do
          view = __MODULE__.__mine__(:views)[unquote(name)]

          for {key, %{as: as, default: def}} <- view.aliases, into: %{} do
            case Map.get(source, as) do
              nil -> {key, def}
              other -> {key, other}
            end
          end
        end

        def from_view(source, name = unquote(name)) do
          with normalized = normalize(source, name),
               {:ok, struct} <- new_instance(normalized),
               {:ok, valid_struct} <- validate(struct) do
            {:ok, valid_struct}
          end
        end

        defoverridable __mine__: 1

        Mine.__deactivate_name__(__MODULE__)
      end

    quote do
      unquote(prelude)
      unquote(body)
      unquote(postlude)
    end
  end

  def __build_view__(mod, name) do
    %{
      mine_aliases: aliases,
      mine_additional_fields: extras,
      mine_ignored: ignored
    } = Mine.__extract_name_info__(mod, name)

    struct_view =
      Module.get_attribute(mod, :struct)
      |> Map.from_struct()
      |> Enum.map(fn {k, v} -> {k, Mine.Alias.new(Atom.to_string(k), v)} end)
      |> Enum.into(%{})

    validate_keys!(mod, name, struct_view, aliases, :alias_field)
    validate_keys!(mod, name, struct_view, ignored, :ignore)

    for {k, _} <- ignored do
      if Map.has_key?(aliases, k) do
        raise Mine.View.CompileError,
          module: mod,
          view: name,
          message: """
          #{k} is used in both alias_field/1 and ignore_field/1.

          Remove either declaration to resolve this conflict.
          """
      end
    end

    aliases =
      struct_view
      |> Map.merge(aliases, &Mine.Alias.merge/3)
      |> Map.drop(Map.keys(ignored))

    Mine.View.new(aliases, extras)
  end

  def __extract_name_info__(mod, name) do
    ~w(mine_aliases mine_additional_fields mine_ignored)a
    |> Enum.map(&{&1, Module.get_attribute(mod, &1)})
    |> Enum.map(fn {attr, kw} -> {attr, Mine.get_name(kw, name)} end)
    |> Enum.into(%{})
  end

  def validate_keys!(mod, name, struct_map, declared, declared_in) do
    Enum.each(declared, fn {key, _} ->
      unless Map.has_key?(struct_map, key) do
        valid_keys =
          struct_map
          |> Map.keys()
          |> Enum.map(&Atom.to_string/1)
          |> Enum.map(&to_string/1)
          |> Enum.join(", ")

        raise Mine.View.CompileError,
          module: mod,
          view: name,
          message: """
          #{key} was assigned in #{declared_in}, but it does not exist in \
          the corresponding struct.

          Valid keys for %#{mod}{} include: #{valid_keys}
          """
      end
    end)
  end

  def has_struct?(module) when is_atom(module) do
    Module.defines?(module, {:__struct__, 0}) && Module.defines?(module, {:__struct__, 1})
  end

  def get_name(list, name) when is_list(list) do
    list
    |> Enum.filter(fn {v, _} -> v == name end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.into(%{})
  end

  # Macros

  defmacro alias_field(key, opts) when is_list(opts) do
    quote do
      Mine.__alias_field__(__MODULE__, unquote(key), unquote(opts))
    end
  end

  defmacro alias_field(key, as) do
    quote do
      Mine.__alias_field__(__MODULE__, unquote(key), as: unquote(as))
    end
  end

  defmacro add_field(key, value) do
    quote do
      Mine.__add_field__(__MODULE__, unquote(key), unquote(value))
    end
  end

  defmacro ignore_field(key) do
    quote do
      Mine.__ignore_field__(__MODULE__, unquote(key))
    end
  end

  defmacro default_view(name) do
    quote do
      Mine.__set_default_view__(__MODULE__, unquote(name))
    end
  end

  # Macro callbacks

  def __alias_field__(mod, key, opts) do
    name = __active_name__(mod, :alias_field)
    {as, opts} = Keyword.pop(opts, :as, Atom.to_string(key))
    {default, _opts} = Keyword.pop(opts, :default)

    Module.get_attribute(mod, :mine_aliases)
    |> Enum.each(fn
      {^name, {^key, _}} ->
        raise Mine.View.CompileError,
          module: mod,
          view: name,
          message: "#{key} has already been aliased"

      _ ->
        false
    end)

    Module.put_attribute(mod, :mine_aliases, {name, {key, Mine.Alias.new(as, default)}})
  end

  def __add_field__(mod, key, value) do
    name = __active_name__(mod, :add_field)
    Module.put_attribute(mod, :mine_additional_fields, {name, {key, value}})
  end

  def __ignore_field__(mod, key) do
    name = __active_name__(mod, :ignore)
    Module.put_attribute(mod, :mine_ignored, {name, {key, []}})
  end

  def __set_default_view__(mod, name) do
    Module.put_attribute(mod, :mine_default_view, name)
  end

  def __active_name__(mod, caller) when is_atom(caller) do
    case Module.get_attribute(mod, :mine_name) do
      nil ->
        raise Mine.View.CompileError,
          module: mod,
          message: """
          #{caller} cannot be used outside defview/1.
          """

      other ->
        other
    end
  end

  def __activate_name__(mod, v) do
    Module.put_attribute(mod, :mine_name, v)
  end

  def __deactivate_name__(mod) do
    Module.put_attribute(mod, :mine_name, :default)
  end

  def __save_view__(mod, name, build) do
    prev = Module.get_attribute(mod, :mine_builds)
    Module.put_attribute(mod, :mine_names, name)
    Module.put_attribute(mod, :mine_builds, Map.put(prev, name, build))
  end

  def __after_compile__(%{module: mod}, _byte_code) do
    default = mod.__mine__(:default_view)
    names = mod.__mine__(:names)

    if not (default in names) do
      raise Mine.View.CompileError,
        module: mod,
        message: """
        Default view is set to #{inspect(default)}, but this view does not exist.

        To set the default view, use the set_default_view/1 macro.

        Alternatively, modules that only use defview/1 once may omit a view name.
        """
    end
  end

  def valid_key?(val) when is_atom(val) or is_binary(val), do: true

  def valid_key?(_), do: false
end
