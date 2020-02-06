defmodule Mine.Registry do
  @moduledoc false

  @registry_name ViewRegistry

  def start_link do
    case Registry.start_link(keys: :unique, name: @registry_name) do
      {:error, {:already_started, pid}} -> {:ok, pid}
      other -> other
    end
  end

  def start_view_agent(mod, view_name) do
    Mine.View.start_link(mod, view_name, name: via(mod, view_name))
  end

  def lookup(mod, view_name), do: lookup(agent_name(mod, view_name))

  def lookup(name) do
    found = Registry.lookup(@registry_name, name)

    case found do
      [{pid, _}] -> {:ok, pid}
      [] -> {:error, :not_found}
    end
  end

  def shutdown_view_agent(mod, view_name) do
    agent_name = agent_name(mod, view_name)

    Registry.unregister(@registry_name, agent_name)

    # a bit of optimism...
    case lookup(agent_name) do
      {:ok, pid} -> Mine.View.stop(pid)
      _ -> :ok
    end
  end

  defp via(mod, view_name) do
    {:via, Registry, {@registry_name, agent_name(mod, view_name)}}
  end

  defp agent_name(mod, view_name) do
    to_string(mod) <> "." <> to_string(view_name)
  end
end
