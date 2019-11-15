defmodule Mine.View.CompileError do
  defexception [:message]

  @impl true
  def exception(opts) when is_list(opts) do
    module = Keyword.get(opts, :module)
    view = Keyword.get(opts, :view, "n/a")
    msg = Keyword.get(opts, :message)

    message = "#{module} (view: #{view}): #{msg}"
    %__MODULE__{message: message}
  end
end
