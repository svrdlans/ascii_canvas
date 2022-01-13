defmodule AC.WebApi.Router do
  use AC.WebApi, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AC.WebApi.Canvas do
    pipe_through :api

    get "/canvases", Controller, :index
    get "/canvases/:id", Controller, :show
    post "/canvases", Controller, :create
    delete "/canvases/:id", Controller, :delete
    put "/canvases/:id/draw_rectangle", Controller, :draw_rectangle
    put "/canvases/:id/flood_fill", Controller, :flood_fill
  end
end
