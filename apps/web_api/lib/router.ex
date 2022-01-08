defmodule AC.WebApi.Router do
  use AC.WebApi, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AC.WebApi do
    pipe_through :api

    get "/canvases", Canvas.Controller, :index
    post "/canvases", Canvas.Controller, :create
    put "/canvases/:canvas_id/draw_rectangle", Canvas.Controller, :draw_rectangle
    put "/canvases/:canvas_id/flood_fill", Canvas.Controller, :flood_fill
  end
end
