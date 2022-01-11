defmodule AC.WebApi.Canvas.RequestHandler do
  @moduledoc """
  Handles or incoming requests.
  """
  alias AC.WebApi.Canvas

  @type response() :: {:ok, Canvas.uuid()} | {:validation_error, Ecto.Changeset.t()}

  @spec process(
          params :: map(),
          validator :: (map -> Ecto.Changeset.t()),
          handler :: (Ecto.Changeset.t() -> response())
        ) :: response()
  def process(params, validator, handler) do
    params
    |> validator.()
    |> handler.()
  end
end
