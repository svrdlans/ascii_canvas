import Config

config :ac_web_api,
  namespace: AC.WebApi

config :ac_web_api, AC.WebApi.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "4P/ww0TY6vBEZgTv1cAhWkd0pw+XVACX3T9DCYe5fHDyqZgKRDaijGkuGp5zOcU1",
  pubsub_server: AC.WebApi.PubSub

config :ac_web_api, table_name: :canvases

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
