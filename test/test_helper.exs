ExUnit.start()

defmodule CompilerAssertions do
  # with some help from: https://gist.github.com/henrik/1054546364ac68da4102
  defmacro assert_compiler_raise(expected_message, error_type \\ Mine.View.CompileError, quoted) do
    quote do
      assert_raise(unquote(error_type), unquote(expected_message), fn ->
        unquote(Macro.escape(quoted))
        |> Code.eval_quoted()
      end)
    end
  end

  defmacro assert_compiles(quoted) do
    quote do
      unquote(Macro.escape(quoted))
      |> Code.eval_quoted()
    end
  end
end
