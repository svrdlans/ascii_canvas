defmodule AC.WebApi.Endpoint do
  use Phoenix.Endpoint, otp_app: :ac_web_api

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.Head
  plug AC.WebApi.Router
end
