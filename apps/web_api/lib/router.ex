defmodule AC.WebApi.Router do
  use AC.WebApi, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AC.WebApi do
    pipe_through :api

    get "/canvases", Canvas.Controller, :index
    get "/canvases/:id", Canvas.Controller, :show
    post "/canvases", Canvas.Controller, :create
    delete "/canvases/:id", Canvas.Controller, :delete
    put "/canvases/:id/draw_rectangle", Canvas.Controller, :draw_rectangle
    put "/canvases/:id/flood_fill", Canvas.Controller, :flood_fill

    match :*, "/*path", DefaultController, :not_found
  end
end
