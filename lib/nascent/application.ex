defmodule Nascent.Application do
  @moduledoc false

  @app :nascent

  use Application

  def start(_type, _args) do
    children = []

    opts = [strategy: :one_for_one, name: Nascent.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp app_config() do
    Application.get_all_env(@app)
  end
end
