defmodule AC.WebApi.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = _get_children()
    opts = [strategy: :one_for_one, name: AC.WebApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  case Mix.env() do
    :test ->
      defp _get_children() do
        []
      end

    _ ->
      def _get_children() do
        table_name = Application.get_env(:ac_web_api, :table_name)

        [
          AC.WebApi.Telemetry,
          {Phoenix.PubSub, name: AC.WebApi.PubSub},
          {AC.WebApi.Repo, table_name: table_name},
          AC.WebApi.Endpoint
        ]
      end
  end
end
