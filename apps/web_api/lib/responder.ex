defmodule AC.WebApi.Responder do
  import Plug.Conn, only: [put_status: 2, send_resp: 3]
  import Phoenix.Controller, only: [json: 2]

  alias AC.WebApi.Helpers.MapHelper
  alias AC.WebApi.ErrorHelpers

  @spec respond_on(
          {:ok, [%{__struct__: module()}]}
          | {:created, binary()}
          | {:validation_error, Ecto.Changeset.t()},
          Plug.Conn.t()
        ) :: Plug.Conn.t()
  def respond_on(:ok, %Plug.Conn{} = conn) do
    conn
    |> send_resp(204, "")
  end

  def respond_on({:ok, list}, %Plug.Conn{} = conn) when is_list(list) do
    payload = MapHelper.from_struct(list)

    conn
    |> put_status(200)
    |> json(payload)
  end

  def respond_on({:ok, %{__struct__: AC.WebApi.Canvas} = canvas}, %Plug.Conn{} = conn) do
    payload = Map.from_struct(canvas)

    conn
    |> put_status(200)
    |> json(payload)
  end

  def respond_on({:created, canvas_id}, %Plug.Conn{} = conn) do
    payload = %{id: canvas_id}

    conn
    |> put_status(201)
    |> json(payload)
  end

  def respond_on({:error, :not_found}, %Plug.Conn{} = conn) do
    conn
    |> send_resp(404, "")
  end

  def respond_on({:validation_error, changeset}, %Plug.Conn{} = conn) do
    payload = changeset |> Ecto.Changeset.traverse_errors(&ErrorHelpers.translate_error/1)

    conn
    |> put_status(422)
    |> json(payload)
  end

  def respond_on({:error, :internal_error}, %Plug.Conn{} = conn) do
    payload = %{error: "Internal error"}

    conn
    |> put_status(503)
    |> json(payload)
  end
end
