defmodule Mine do
  @type key :: atom | String.t()
  defguardp is_valid_key?(val) when is_atom(val) or is_binary(val)

  defmacro __using__(_) do
    quote do
      import Mine

      @mine true
      @mine_default_view :default
      @mine_views %{}
      @mine_aliases %{}
      @mine_additional_fields %{}
      @mine_ignored %{}

      Module.register_attribute(__MODULE__, :mine_name, accumulate: false)
      Module.register_attribute(__MODULE__, :mine_names, accumulate: true)

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
        unless valid_key?(unquote(name)) do
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

        aliases = @mine_aliases
        ignored = @mine_ignored
        additional = @mine_additional_fields
        views = @mine_views
        default = @mine_default_view
        names = @mine_names |> Enum.reverse()

        def __mine__(:aliases), do: unquote(Macro.escape(aliases))
        def __mine__(:ignored), do: unquote(Macro.escape(ignored))
        def __mine__(:additional), do: unquote(Macro.escape(additional))
        def __mine__(:views), do: unquote(Macro.escape(views))
        def __mine__(:default_view), do: unquote(default)
        def __mine__(:names), do: unquote(names)

        for {name, view} <- views do
          def __mine__({:view, unquote(name)}), do: unquote(Macro.escape(view))
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

  @doc """
  Constructs a valid view for `name` to be used during runtime. Accesses the
  attributes `mod` for the bindings made within the `defview/2` macro.
  """
  @spec __build_view__(module, key) :: Mine.ViewDefinition.t()
  def __build_view__(mod, name) do
    %{
      mine_aliases: aliases,
      mine_additional_fields: additional,
      mine_ignored: ignored
    } = Mine.__get_name_values__(mod, name)

    struct_view =
      Module.get_attribute(mod, :struct)
      |> Map.from_struct()
      |> Enum.map(fn {k, v} -> {k, Mine.Alias.new(Atom.to_string(k), v)} end)
      |> Enum.into(%{})

    Mine.__validate_keys__(mod, name, struct_view, aliases, :alias_field)
    Mine.__validate_keys__(mod, name, struct_view, ignored, :ignore)

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

    Mine.ViewDefinition.new(aliases, additional)
  end

  @doc """
  Fetches the current values stored in the attributes for `mod` stored for `name`.

  Expects that the content of each attribute is a map that contains the key `name`.
  """
  @spec __get_name_values__(module, key) :: %{atom => %{key => any}}
  def __get_name_values__(mod, name) when is_valid_key?(name) do
    for attr <- ~w(mine_aliases mine_additional_fields mine_ignored)a, into: %{} do
      {attr, Module.get_attribute(mod, attr)[name]}
    end
  end

  @doc """
  Saves the given `key`, `value` pair into the map of `attribute` on `mod`.

  Assumes that `attribute` has is a map containing the key `name`.

  Raises if `key` has already been used by the `caller`.
  """
  @spec __put_into_attribute__(module, atom, key, key, any) :: :ok
  def __put_into_attribute__(mod, attribute, name, key, value) do
    name_map = Module.get_attribute(mod, attribute)

    unless is_nil(get_in(name_map, [name, key])) do
      caller =
        case attribute do
          :mine_aliases -> :alias_field
          :mine_additional_fields -> :add_field
          :mine_ignored -> :ignore_field
        end

      raise Mine.View.CompileError,
        module: mod,
        view: name,
        message: "#{key} has already been assigned using #{caller} in this view"
    end

    Module.put_attribute(mod, attribute, put_in(name_map, [name, key], value))
  end

  @doc """
  Checks whether every key in the `declared` map is in `struct_map`.

  Raises on undeclared key.
  """
  @spec __validate_keys__(module, key, %{atom => any}, %{key => any}, atom) :: :ok
  def __validate_keys__(mod, name, struct_map, declared, declared_in) do
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

    :ok
  end

  @doc """
  Checks if `mod` has declared the functions required to be a struct.
  """
  @spec has_struct?(module) :: boolean
  def has_struct?(mod) when is_atom(mod) do
    Module.defines?(mod, {:__struct__, 0}) && Module.defines?(mod, {:__struct__, 1})
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

  @doc """
  Adds an alias for `field` for the view that is currently in scope. `opts` are used
  to construct an instance of `Mine.Alias`.
  """
  @spec __alias_field__(module, key, keyword) :: :ok
  def __alias_field__(mod, field, opts) do
    name = __active_name__(mod, :alias_field)
    as = Keyword.get(opts, :as, Atom.to_string(field))
    default = Keyword.get(opts, :default)

    Mine.__put_into_attribute__(mod, :mine_aliases, name, field, Mine.Alias.new(as, default))
  end

  @doc """
  Specifies that view in the surrounding scope will add the `key` => `value` to
  the views it produces.
  """
  @spec __add_field__(module, key, any) :: :ok
  def __add_field__(mod, field, value) do
    name = __active_name__(mod, :add_field)
    Mine.__put_into_attribute__(mod, :mine_additional_fields, name, field, value)
  end

  @doc """
  Specifies that the surrounding view will ignore `field` when mapping to and
  from the struct for `mod`.
  """
  @spec __ignore_field__(module, key) :: :ok
  def __ignore_field__(mod, field) do
    name = __active_name__(mod, :ignore_field)
    Mine.__put_into_attribute__(mod, :mine_ignored, name, field, [])
  end

  @doc "Sets the `@mine_default_view` attribute for `mod`."
  @spec __set_default_view__(module, key) :: :ok
  def __set_default_view__(mod, name) do
    Module.put_attribute(mod, :mine_default_view, name)
  end

  @doc """
  Inspects the attributes of `mod` for the name of the current view.

  If a current name has not been set, the calling macro was not inside
  a `defview` block and this will raise. Uses `caller` to provide a
  descriptive error message.
  """
  @spec __active_name__(module, atom) :: atom
  def __active_name__(mod, caller) when is_atom(caller) do
    case Module.get_attribute(mod, :mine_name) do
      nil ->
        # no active name implies macro was out of scope
        raise Mine.View.CompileError,
          module: mod,
          message: """
          #{caller} cannot be used outside defview/1.
          """

      name ->
        name
    end
  end

  @doc """
  Set the current view name of `mod` to `name`. This is should be inserted some
  point before the body of `defview/2`.

  Basically using this to start a scope.
  """
  @spec __activate_name__(module, key) :: :ok
  def __activate_name__(mod, name) do
    # prepare entries for this context
    for attr <- ~w(mine_aliases mine_additional_fields mine_ignored)a do
      name_values = Module.get_attribute(mod, attr)
      Module.put_attribute(mod, attr, Map.put(name_values, name, %{}))
    end

    Module.put_attribute(mod, :mine_name, name)
  end

  @doc "Exits the scope of `mod` by clearing `@mine_name`"
  @spec __deactivate_name__(module) :: :ok
  def __deactivate_name__(mod) do
    Module.delete_attribute(mod, :mine_name)
  end

  @doc "Saves a validated view to the attributes of `mod` with the name `name`"
  @spec __save_view__(module, key, Mine.ViewDefinition.t()) :: :ok
  def __save_view__(mod, name, view) do
    prev = Module.get_attribute(mod, :mine_views)
    Module.put_attribute(mod, :mine_names, name)
    Module.put_attribute(mod, :mine_views, Map.put(prev, name, view))
  end

  @doc false
  @spec __after_compile__(map, any) :: :ok
  def __after_compile__(%{module: mod}, _byte_code) do
    default = mod.__mine__(:default_view)
    names = mod.__mine__(:names)

    unless default in names do
      raise Mine.View.CompileError,
        module: mod,
        message: """
        Default view is set to #{inspect(default)}, but this view does not exist.

        To set the default view, use the set_default_view/1 macro.

        Alternatively, modules that only use defview/1 once may omit a view name.
        """
    else
      :ok
    end
  end

  @spec valid_key?(any) :: boolean
  def valid_key?(val) when is_valid_key?(val), do: true

  def valid_key?(_), do: false
end
