defmodule AC.WebApi.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AC.WebApi.Telemetry,
      {Phoenix.PubSub, name: AC.WebApi.PubSub},
      AC.WebApi.Endpoint
    ]

    opts = [strategy: :one_for_one, name: AC.WebApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    AC.WebApi.Endpoint.config_change(changed, removed)
    :ok
  end
end
