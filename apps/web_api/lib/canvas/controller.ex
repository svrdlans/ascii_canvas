defmodule AC.WebApi.Canvas.Controller do
  use AC.WebApi, :controller

  alias AC.WebApi.Canvas.RequestHandler
  alias AC.WebApi.Canvas.Requests
  alias AC.WebApi.Canvas.Handlers
  alias AC.WebApi.Responder

  def index(conn, _params) do
    Handlers.Index.handle()
    |> Responder.respond_on(conn)
  end

  def create(conn, params) do
    params
    |> RequestHandler.process(&Requests.Create.validate/1, &Handlers.Create.handle/1)
    |> Responder.respond_on(conn)
  end

  def delete(conn, params) do
    params
    |> RequestHandler.process(&Requests.Delete.validate/1, &Handlers.Delete.handle/1)
    |> Responder.respond_on(conn)
  end

  def draw_rectangle(conn, params) do
    params
    |> RequestHandler.process(
      &Requests.DrawRectangle.validate/1,
      &Handlers.DrawRectangle.handle/1
    )
    |> Responder.respond_on(conn)
  end

  def flood_fill(conn, _params) do
    conn
  end
end
