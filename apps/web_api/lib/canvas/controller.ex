defmodule AC.WebApi.Canvas.Controller do
  use AC.WebApi, :controller

  alias AC.WebApi.Canvas.RequestHandler
  alias AC.WebApi.Canvas.Requests
  alias AC.WebApi.Canvas.Handlers
  alias AC.WebApi.RepoAPI
  alias AC.WebApi.Responder

  def index(conn, _params) do
    Handlers.Index.handle(RepoAPI)
    |> Responder.respond_on(conn)
  end

  def show(conn, params) do
    params
    |> RequestHandler.process(&Requests.Show.validate/2, &Handlers.Show.handle/2, RepoAPI)
    |> Responder.respond_on(conn)
  end

  def create(conn, params) do
    params
    |> RequestHandler.process(&Requests.Create.validate/2, &Handlers.Create.handle/2, RepoAPI)
    |> Responder.respond_on(conn)
  end

  def delete(conn, params) do
    params
    |> RequestHandler.process(&Requests.Delete.validate/2, &Handlers.Delete.handle/2, RepoAPI)
    |> Responder.respond_on(conn)
  end

  def draw_rectangle(conn, params) do
    params
    |> RequestHandler.process(
      &Requests.DrawRectangle.validate/2,
      &Handlers.DrawRectangle.handle/2,
      RepoAPI
    )
    |> Responder.respond_on(conn)
  end

  def flood_fill(conn, params) do
    params
    |> RequestHandler.process(
      &Requests.FloodFill.validate/2,
      &Handlers.FloodFill.handle/2,
      RepoAPI
    )
    |> Responder.respond_on(conn)
  end
end
