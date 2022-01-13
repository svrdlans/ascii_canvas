defmodule AC.WebApi.Canvas.Controller do
  use AC.WebApi, :controller

  alias AC.WebApi.Canvas.RequestHandler
  alias AC.WebApi.Canvas.Requests
  alias AC.WebApi.Canvas.Handlers
  alias AC.WebApi.Responder
  alias AC.WebApi.Helpers.AppConfig

  def index(conn, _params) do
    {:ok, repo} = AppConfig.get_repo_name()

    Handlers.Index.handle(repo)
    |> Responder.respond_on(conn)
  end

  def create(conn, params) do
    {:ok, repo} = AppConfig.get_repo_name()

    params
    |> RequestHandler.process(&Requests.Create.validate/2, &Handlers.Create.handle/2, repo)
    |> Responder.respond_on(conn)
  end

  def delete(conn, params) do
    {:ok, repo} = AppConfig.get_repo_name()

    params
    |> RequestHandler.process(&Requests.Delete.validate/2, &Handlers.Delete.handle/2, repo)
    |> Responder.respond_on(conn)
  end

  def draw_rectangle(conn, params) do
    {:ok, repo} = AppConfig.get_repo_name()

    params
    |> RequestHandler.process(
      &Requests.DrawRectangle.validate/2,
      &Handlers.DrawRectangle.handle/2,
      repo
    )
    |> Responder.respond_on(conn)
  end

  def flood_fill(conn, _params) do
    conn
  end
end
