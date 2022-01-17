defmodule AC.WebApi.Canvas.RequestHandler do
  @moduledoc """
  Handles all incoming requests.

  Every request is received as a message so that
  request order is guaranteed.
  """
  use GenServer

  alias AC.WebApi.Canvas
  require Logger

  @type response() ::
          :ok
          | {:ok, Canvas.uuid()}
          | {:validation_error, Ecto.Changeset.t()}
          | {:error, :not_found}

  def start_link(_),
    do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

  def init(_),
    do: {:ok, nil}

  @spec process(
          params :: map(),
          validator :: (map, nil | module() -> Ecto.Changeset.t() | {:error, :not_found}),
          handler :: (Ecto.Changeset.t(), module() | {:error, :not_found} -> response()),
          repo :: module()
        ) :: response()
  def process(params, validator, handler, repo),
    do: GenServer.call(__MODULE__, {:process, params, validator, handler, repo})

  def handle_call({:process, params, validator, handler, repo}, _from, state) do
    result =
      try do
        params
        |> validator.(repo)
        |> handler.(repo)
      rescue
        error ->
          Logger.error("[RequestHandler] Processing request failed, reason: #{inspect(error)}")
          {:error, :internal_error}
      end

    {:reply, result, state}
  end
end
