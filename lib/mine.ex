defmodule Mine do
  @type key :: atom | String.t()
  defguardp is_valid_key?(val) when is_atom(val) or is_binary(val)

  defmacro __using__(_opts) do
    quote do
      import Mine

      @mine true
      @mine_default_view :default
      @mine_views %{}
      @mine_current nil

      Module.register_attribute(__MODULE__, :mine_name, accumulate: false)
      Module.register_attribute(__MODULE__, :mine_names, accumulate: true)

      {:ok, _} = Mine.Registry.start_link()
      @after_compile {Mine, :finalize_view}

      def __mine__(:default_view), do: @mine_default_view
      def __mine__(:names), do: Module.get_attribute(__MODULE__, :mine_names)
      defoverridable __mine__: 1

      def to_view(struct, name \\ __MODULE__.__mine__(:default_view))
      def from_view(source, name \\ __MODULE__.__mine__(:default_view))
    end
  end

  defmacro defview(name \\ :default, do: body) do
    prelude =
      quote bind_quoted: [name: name] do
        unless valid_key?(name) do
          raise Mine.View.CompileError,
            module: __MODULE__,
            view: name,
            message: """
            not a valid view name

            Acceptable types are: Atom, Binary
            """
        end

        unless has_struct?(__MODULE__) do
          raise Mine.View.CompileError,
            module: __MODULE__,
            view: name,
            message: """
            must define a struct to use #{inspect(Mine)}

            Make sure #{inspect(__MODULE__)} uses defstruct/1 before defview.
            """
        end

        if Enum.any?(@mine_names, &(&1 == name)) do
          raise Mine.View.CompileError,
            module: __MODULE__,
            view: name,
            message: """
            view names must be unique.

            #{name} has already been declared in this module.
            """
        end

        # save name to list
        @mine_names name
        # set current view name
        @mine_current name

        # start an agent to keep track of state for this view
        {:ok, _} = Mine.Registry.start_view_agent(__MODULE__, name)
      end

    postlude =
      quote bind_quoted: [name: name] do
        {:ok, view_agent} = Mine.Registry.lookup(__MODULE__, name)

        view = Mine.View.compose(view_agent)
        default_view = @mine_default_view
        names = @mine_names

        def __mine__(:default_view), do: unquote(default_view)
        def __mine__(:names), do: unquote(Macro.escape(names))
        def __mine__({:view, unquote(name)}), do: unquote(Macro.escape(view))
        defoverridable __mine__: 1

        to_view = Mine.Builder.build_to_view(__MODULE__, name, view)
        from_view = Mine.Builder.build_from_view(__MODULE__, name, view)

        Module.eval_quoted(__MODULE__, to_view)
        Module.eval_quoted(__MODULE__, from_view)

        # shut down agent for this view
        Mine.View.stop(view_agent)
      end

    quote do
      unquote(prelude)
      unquote(body)
      unquote(postlude)
    end
  end

  @doc """
  Checks if `mod` has declared the functions required to be a struct at compile
  time.
  """
  @spec has_struct?(module) :: boolean
  def has_struct?(mod) when is_atom(mod) do
    Module.defines?(mod, {:__struct__, 0}) && Module.defines?(mod, {:__struct__, 1})
  end

  # Macros

  defmacro alias_field(key, opts) when is_list(opts) do
    quote do
      Mine.__alias_field__(
        __MODULE__,
        Module.get_attribute(__MODULE__, :mine_current),
        unquote(key),
        unquote(opts)
      )
    end
  end

  defmacro alias_field(key, as) do
    quote do
      Mine.__alias_field__(
        __MODULE__,
        Module.get_attribute(__MODULE__, :mine_current),
        unquote(key),
        as: unquote(as)
      )
    end
  end

  defmacro add_field(key, value) do
    quote do
      Mine.__add_field__(
        __MODULE__,
        Module.get_attribute(__MODULE__, :mine_current),
        unquote(key),
        unquote(value)
      )
    end
  end

  defmacro ignore_field(key) do
    quote do
      Mine.__ignore_field__(
        __MODULE__,
        Module.get_attribute(__MODULE__, :mine_current),
        unquote(key)
      )
    end
  end

  defmacro default_view(name) do
    quote do
      Mine.__set_default_view__(__MODULE__, unquote(name))
    end
  end

  # Macro callbacks

  def __alias_field__(mod, view_name, key, opts) when is_list(opts) do
    get_view!(mod, view_name, :alias_field)
    |> Mine.View.add_alias_field(key, struct(Mine.Alias, opts))
    |> handle_view_call(mod, view_name, key)
  end

  def __add_field__(mod, view_name, key, value) do
    get_view!(mod, view_name, :add_field)
    |> Mine.View.add_additional_field(key, value)
    |> handle_view_call(mod, view_name, key)
  end

  def __ignore_field__(mod, view_name, key) do
    get_view!(mod, view_name, :ignore_field)
    |> Mine.View.add_ignored_field(key)
    |> handle_view_call(mod, view_name, key)
  end

  defp handle_view_call(res, mod, view_name, key) do
    case res do
      {:error, :duplicate} ->
        raise Mine.View.CompileError,
          module: mod,
          view: view_name,
          message: "#{key} is defined more than once."

      {:error, :not_found} ->
        raise Mine.View.CompileError,
          module: mod,
          view: view_name,
          message: "#{key} was assigned but it does not exist in the corresponding struct."

      :ok ->
        :ok
    end
  end

  def get_view!(mod, view_name, operation_name \\ nil) do
    case Mine.Registry.lookup(mod, view_name) do
      {:ok, pid} ->
        pid

      {:error, :not_found} ->
        raise Mine.View.CompileError,
          module: mod,
          view: view_name,
          message: "#{operation_name} cannot be used outside defview"
    end
  end

  @doc "Sets the `@mine_default_view` attribute for `mod`."
  @spec __set_default_view__(module, key) :: :ok
  def __set_default_view__(mod, name) do
    Module.put_attribute(mod, :mine_default_view, name)
  end

  @doc """
  Verifies that the declared default key corresponds to an existing view.

  Raises if this condition fails.
  """
  def finalize_view(%{module: mod}, _byte_code) do
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

# defmodule User do
#  use Mine
#
#  defstruct [:name]
#
#  default_view :api
#
#  defview :api do
#    alias_field(:name, "nombre")
#  end
# end
