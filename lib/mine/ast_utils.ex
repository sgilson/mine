defmodule Mine.AstUtils do
  @moduledoc false

  def ast_is_function?(ast) do
    ast_function_info(ast)[:type] != :not_a_function
  end

  ## TODO is it possible to reliably determine arity?
  def ast_function_info(ast) do
    case ast do
      {:&, _, _} -> [type: :capture]
      {:fn, _, _} -> [type: :anonymous]
      _ -> [type: :not_a_function]
    end
  end
end
