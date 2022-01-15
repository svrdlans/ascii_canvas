defmodule AC.WebApi.DefaultController do
  use AC.WebApi, :controller

  def not_found(conn, _params) do
    conn
    |> put_status(404)
    |> json(%{message: "Path not found"})
  end
end
