import Config

config :ac_web_api, namespace: AC.WebApi

config :ac_web_api, AC.WebApi.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: AC.WebApi.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: AC.WebApi.PubSub

config :ac_web_api, :repo, table_name: :canvases

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
