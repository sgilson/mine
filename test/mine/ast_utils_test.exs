defmodule Mine.AstUtilsTest do
  use ExUnit.Case

  import Mine.AstUtils

  describe "ast_is_function/1" do
    test "identifies anonymous function" do
      ast = quote do: fn _x -> 1 end

      assert ast_is_function?(ast)
    end

    test "identifies anonymous function with guard" do
      ast = quote do: fn x when is_integer(x) -> true end

      assert ast_is_function?(ast)
    end

    test "identifies anonymous function with clauses" do
      ast =
        quote do: fn
                1 -> true
                _ -> false
              end

      assert ast_is_function?(ast)
    end

    test "identifies capture" do
      ast = quote do: &ast_is_function?/1

      assert ast_is_function?(ast)
    end

    test "identifies captures of imported functions" do
      ast = quote do: &(ast_is_function?(&1) && &2)

      assert ast_is_function?(ast)
    end

    test "refutes function references" do
      ast = quote do: Mine.AstUtils.ast_is_function?()

      refute ast_is_function?(ast)
    end

    test "refutes lists" do
      ast = quote do: [1, 2, 3]

      refute ast_is_function?(ast)
    end
  end
end
