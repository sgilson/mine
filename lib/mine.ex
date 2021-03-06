defmodule Mine do
  @type key :: atom | String.t()
  @spec valid_key?(any) :: boolean
  @doc false
  def valid_key?(val) when is_atom(val) or is_binary(val), do: true

  def valid_key?(_), do: false

  @type only_opt :: :to_view | :from_view
  @type only_opts :: only_opt() | [only_opt()]

  @typedoc """
  Used to limit which functions are generated by Mine.
  """
  @type using_opts :: [only: only_opts()]

  @spec __using__(using_opts()) :: term()
  defmacro __using__(opts) do
    only =
      opts
      |> Keyword.get(:only)
      |> resolve_only()

    quote do
      import Mine, only: [defview: 0, defview: 1, defview: 2, default_view: 1]

      @mine true
      @mine_default_view :default
      @mine_current_name nil
      @mine_only unquote(only)

      Module.register_attribute(__MODULE__, :mine_name, accumulate: false)
      Module.register_attribute(__MODULE__, :mine_names, accumulate: true)

      # @on_definition {Mine, :on_def}
      @before_compile Mine
      @after_compile Mine

      def __mine__(:default_view), do: @mine_default_view
      def __mine__(:names), do: Module.get_attribute(__MODULE__, :mine_names)
      defoverridable __mine__: 1

      if Enum.member?(@mine_only, :to_view) do
        def to_view(struct, name \\ __MODULE__.__mine__(:default_view))
      end

      if Enum.member?(@mine_only, :from_view) do
        def from_view(source, name \\ __MODULE__.__mine__(:default_view))
      end
    end
  end

  @doc """
  Used to specify the requirements for generating `to_view` and `from_view` functions
  on a module.

  Within the scope of this macro, `Mine.field/2`, `Mine.append/2`, and
  `Mine.ignore/1` will be in scope.

  The `name` argument is a value used to identify this view when invoking the
  generated `to_view` and `from_view` functions. This defaults to, well, `:default`.

  If there are multiple views declared in a module and you wish to change the
  default behavior of the single arity `to_view` and `from_view` functions,
  use `Mine.default_view/1`.

  Note that any fields that exist in the modules struct and are not explicitly
  ignored with a call to `Mine.ignore/1` will not be ignored. This behavior
  may be configurable in the future.

  Annotations can be placed before `defview` to augment the view.

  - `@default_view`: if passed `true`, indicates that the following view should be the
    default. It can also be passed the name of a view, similar to `Mine.default_view/1`.
  - `@exclude_if`: should be passed a function with arity 1 that returns `true` or `false`.
    Used to filter values maps resulting from a call to `to_view`. This is useful for when
    empty fields should not be included in the final data representation. Two helper
    functions can be referenced using atoms: `:is_nil` (entries whose values are nil will be
    filtered out), and `:is_blank` (entries whose values are nil or an empty string are removed).
  """
  @spec defview(Mine.key(), do: term()) :: term()
  defmacro defview(name, do: body) do
    prelude =
      quote bind_quoted: [name: name],
            unquote: true do
        Mine.validate_defview!(__MODULE__, __ENV__, name)

        @mine_names name
        @mine_current_name name
        @mine_current_view Mine.View.new(__MODULE__, name)

        Mine.handle_attributes!(__MODULE__, name)

        try do
          import Mine, only: [field: 2, append: 2, ignore: 1]
          unquote(body)
        after
          :ok
        end
      end

    postlude =
      quote bind_quoted: [name: name] do
        {composed_view, view} =
          Module.get_attribute(__MODULE__, :mine_current_view)
          |> Mine.View.compose()

        default_view = Module.get_attribute(__MODULE__, :mine_default_view)
        names = Module.get_attribute(__MODULE__, :mine_names)

        def __mine__(:default_view), do: unquote(default_view)
        def __mine__(:names), do: unquote(Macro.escape(names))
        def __mine__({:view, unquote(name)}), do: unquote(Macro.escape(composed_view))

        defoverridable __mine__: 1

        # Optionally generate the to_view and from_view functions

        if Enum.member?(Module.get_attribute(__MODULE__, :mine_only), :to_view) do
          to_view = Mine.Builder.build_to_view(__MODULE__, view, composed_view)
          Module.eval_quoted(__ENV__, to_view)
        end

        if Enum.member?(Module.get_attribute(__MODULE__, :mine_only), :from_view) do
          from_view = Mine.Builder.build_from_view(__MODULE__, view, composed_view)
          Module.eval_quoted(__ENV__, from_view)
        end

        Module.delete_attribute(__MODULE__, :mine_current_view)
      end

    quote do
      unquote(prelude)
      unquote(postlude)
    end
  end

  @doc false
  @spec defview() :: term()
  defmacro defview() do
    quote do: Mine.defview(:default, do: :ok)
  end

  @spec defview(Mine.key() | [do: term()]) :: term()

  @doc false
  defmacro defview(do: body) do
    quote do: Mine.defview(:default, do: unquote(body))
  end

  @doc false
  defmacro defview(name) do
    quote do: Mine.defview(unquote(name), do: :ok)
  end

  @doc false
  @spec validate_defview!(module(), Macro.Env.t(), any()) :: %{__struct__: module()}
  def validate_defview!(mod, env, name) do
    validate_name!(mod, name)
    Macro.struct!(mod, env)
  end

  # Macros

  @type field_opt ::
          {:default, any()}
          | {:as, Mine.key()}
          | {:map_from, (any() -> any())}
          | {:map_to, (any() -> any())}
  @type field_opts :: [field_opt()]
  @spec field(Mine.key(), field_opts() | Mine.key()) :: term()
  @doc """
  Changes the name use to identify a field in an external view.

  There are many cases where the name you use for a field within your Elixir
  application is not the name used outside of your application. This is
  especially apparent when interfacing with an API that defines variables
  in camel case. Since we conventionally represent atoms (and therefore the keys
  of structs) in snake case, this can lead to code mapping field names to and
  from the external naming convention.

  `field/2` is a simpler way to represent this relationship.

  Options:

  - as: Name to use when mapping to/from an external view
  - default: Value to be used when struct does not contain an entry for the
    given key
  - map_to: Function with arity 1 that will be invoked on the existing value
    in the struct when using `to_view`
  - map_from: Function with arity 1 that will be invoked on the value found in
    the external view when using `from_view`

  Example:

      defmodule MyModule do
        use Mine
        defstruct [:my_field, :foo, :to_upper]

        defview do
          field :my_field, as: "myField"
          field :foo, default: "bar"
          field :to_upper, map_to: &String.upcase/1
        end
      end

      MyModule.to_view(%MyModule{my_field: 1, to_upper: "upper!"})
      # %{"myField" => 1, "foo" => "bar", "to_upper" => "UPPER!"}
  """
  defmacro field(key, opts) when is_list(opts) do
    quote do
      Mine.__field__(__MODULE__, unquote(key), unquote(Macro.escape(opts)))
    end
  end

  defmacro field(key, as) do
    quote do
      Mine.__field__(__MODULE__, unquote(key), as: unquote(as))
    end
  end

  @spec append(Mine.key(), any()) :: term()
  @doc """
  When `to_view` is invoked, an extra field with the key `key` will be added
  to the resulting map with the value `value`.

  Useful when an external API is not hygienic and requires constant metadata for
  an entity to be properly parsed.

  For example:

      defmodule MyModule do
        use Mine
        defstruct [:field]

        defview do
          append "@class", "Some.Java.Class"
        end
      end

      MyModule.to_view(%MyModule{field: "example"})
      # %{"field" => "example", "@class" => "Some.Java.Class"}
  """
  defmacro append(key, value) do
    quote do
      Mine.__append__(__MODULE__, unquote(key), unquote(Macro.escape(value)))
    end
  end

  @spec ignore(Mine.key()) :: term()
  @doc """
  Declares that the given key will not be considered when mapping a struct in
  either `to_view` or `from_view`.

  For example:

      defmodule MyModule do
        use Mine
        defstruct [:public, :private]

        defview do
          ignore :private
        end
      end

      MyModule.to_view(%MyModule{public: "hello", private: "world"})
      # %{"public" => "hello"}

      MyModule.from_view(%{"public" => "hello", "private" => "world"})
      # %MyModule{public: "hello"}

  A field that has been declared as ignored cannot be used in `Mine.field/2` and
  vice versa. Doing so will raise an error.
  """
  defmacro ignore(key) do
    quote do
      Mine.__ignore__(__MODULE__, unquote(key))
    end
  end

  @spec default_view(Mine.key()) :: term()
  @doc """
  Changes the name of the default view to `name`.

  The default view name will be the fallback parameter for any calls to
  `to_view/1` and `from_view/1`.

  Normally, these functions will be generated with signatures similar to the
  following:

      def to_view(struct = %MyModule{}, view \\\\ :default)
      def from_view(map, view \\\\ :default)

  But declaring `default_view :other` in your module...

      defmodule MyModule do
        use Mine
        # create struct
        default_view :other

        defview :other do
          # ...
        end
      end

  ...yields signatures like these:

      def to_view(struct = %MyModule{}, view \\\\ :other)
      def from_view(map, view \\\\ :other)
  """
  defmacro default_view(name) do
    quote do
      Mine.__set_default_view__(__MODULE__, unquote(name))
    end
  end

  # Macro callbacks

  def __field__(mod, key, opts) when is_list(opts) do
    # ensure :as has a value
    opts = Keyword.put_new_lazy(opts, :as, fn -> Atom.to_string(key) end)

    current_view(mod)
    |> Mine.View.add_alias_field(key, struct(Mine.Alias, opts))
    |> handle_view_update(mod, key)
  end

  def __append__(mod, key, value) do
    current_view(mod)
    |> Mine.View.add_additional_field(key, value)
    |> handle_view_update(mod, key)
  end

  def __ignore__(mod, key) do
    current_view(mod)
    |> Mine.View.add_ignored_field(key)
    |> handle_view_update(mod, key)
  end

  def __set_default_view__(mod, name) do
    Module.put_attribute(mod, :mine_default_view, name)
  end

  def __set_exclude_if__(mod, exclude_if) do
    current_view(mod)
    |> Mine.View.set_exclude_if(exclude_if)
    |> handle_view_update(mod, :exclude_if)
  end

  def __set_naming_strategy__(mod, strategy) do
    current_view(mod)
    |> Mine.View.set_naming_strategy(strategy)
    |> handle_view_update(mod, :naming_strategy)
  end

  defp handle_view_update(res, mod, key) do
    msg =
      case res do
        {:error, :duplicate} ->
          "#{key} is defined more than once."

        {:error, :not_found} ->
          "#{key} was assigned but it does not exist in the corresponding struct."

        {:error, {:invalid_key, key, val}} ->
          "#{inspect(val)} is not a valid value for #{key}. Value must fulfill Mine.is_valid_key?/1"

        {:error, {:not_a_function, val}} ->
          "#{inspect(val)} should be a function"

        {:error, {:invalid_exclude_if, invalid}} ->
          """
          #{inspect(invalid)} should be a remote function in the format &Mod.fun/1

          Valid shortcuts include: :is_nil, :is_blank

          Note: anonymous functions and remote macros are not supportable as of Elixir 1.9
          """

        {:error, {:bad_naming_strategy, strategy, valid}} ->
          """
          Unknown naming strategy: #{strategy}

          Existing naming strategies: #{inspect(valid)}
          """

        {:ok, view} ->
          update_current_view(mod, view)
          :ok
      end

    if msg != :ok do
      raise Mine.View.CompileError,
        module: mod,
        view: Module.get_attribute(mod, :mine_current_name),
        message: msg
    end
  end

  defp current_view(mod), do: Module.get_attribute(mod, :mine_current_view)

  defp update_current_view(mod, view) do
    Module.put_attribute(mod, :mine_current_view, view)
  end

  defmacro __before_compile__(%{module: mod}) do
    if Module.get_attribute(mod, :mine_names) == [] do
      quote do
        # overridable definitions have been made concrete
        # add this again to avoid warnings
        defoverridable __mine__: 1
        defview()
      end
    end
  end

  def __after_compile__(%{module: mod}, _) do
    default = mod.__mine__(:default_view)
    names = mod.__mine__(:names)

    validate_default_name!(mod, names, default)

    :ok
  end

  # Private

  defp validate_name!(mod, name) do
    unless Mine.valid_key?(name) do
      raise Mine.View.CompileError,
        module: mod,
        view: name,
        message: """
        not a valid view name

        Acceptable types are: Atom, Binary
        """
    end

    if Enum.member?(Module.get_attribute(mod, :mine_names, []), name) do
      raise Mine.View.CompileError,
        module: mod,
        view: name,
        message: """
        view names must be unique.

        #{name} has already been declared in this module.
        """
    end
  end

  defp validate_default_name!(mod, names, default_name) do
    unless default_name in names do
      raise Mine.View.CompileError,
        module: mod,
        message: """
        Default view is set to #{inspect(default_name)}, but this view does not exist.

        To set the default view, use the default_view/1 macro.

        Alternatively, you can annotate a view with `@default_view true`.

        Modules that only use defview/1 once may omit a view name.
        """
    end
  end

  @doc false
  def handle_attributes!(mod, view_name) do
    mod
    |> pop_attributes()
    |> handle_default_view_attr!(mod, view_name)
    |> handle_exclude_if_attr!(mod)
    |> handle_naming_strategy!(mod)
  end

  defp handle_default_view_attr!(attributes, mod, view_name) do
    {default_view, next} = Keyword.pop(attributes, :default_view, false)

    default =
      case default_view do
        false -> false
        true -> view_name
        val -> val
      end

    if default, do: __set_default_view__(mod, default)

    next
  end

  defp handle_exclude_if_attr!(attributes, mod) do
    {exclude_if, next} = Keyword.pop(attributes, :exclude_if)

    __set_exclude_if__(mod, exclude_if)

    next
  end

  defp handle_naming_strategy!(attributes, mod) do
    {strategy, next} = Keyword.pop(attributes, :naming_strategy)

    if strategy, do: __set_naming_strategy__(mod, strategy)

    next
  end

  @config_attributes [:default_view, :exclude_if, :naming_strategy]
  defp pop_attributes(mod) do
    for attribute <- @config_attributes, into: [] do
      {attribute, Module.delete_attribute(mod, attribute)}
    end
  end

  defp resolve_only(list) when is_list(list), do: list
  defp resolve_only(:to_view), do: [:to_view]
  defp resolve_only(:from_view), do: [:from_view]
  defp resolve_only(_), do: [:to_view, :from_view]
end
