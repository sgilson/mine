ExUnit.start(exclude: :benchmark)

defmodule CompilerAssertions do
  # credit to https://gist.github.com/henrik/1054546364ac68da4102
  defmacro assert_compile_time_raise(expected_message, quoted) do
    quote do
      assert_raise(Mine.View.CompileError, unquote(expected_message), fn ->
        unquote(Macro.escape(quoted))
        |> Code.eval_quoted()
      end)
    end
  end
end
