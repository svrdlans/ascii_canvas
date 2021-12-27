defmodule AC.WebApi.Router do
  use AC.WebApi, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AC.WebApi do
    pipe_through :api
  end
end
