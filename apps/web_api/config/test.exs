import Config

config :ac_web_api, AC.WebApi.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  server: false

config :ac_web_api, :repo,
  table_name: :canvases_test,
  name: AC.WebApi.TestRepo

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
