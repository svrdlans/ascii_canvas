defmodule AC.WebApi.Canvas.RequestHandler do
  @moduledoc """
  Handles or incoming requests.
  """
  alias AC.WebApi.Canvas

  @type response() ::
          :ok
          | {:ok, Canvas.uuid()}
          | {:validation_error, Ecto.Changeset.t()}
          | {:error, :not_found}

  @spec process(
          params :: map(),
          validator :: (map -> Ecto.Changeset.t() | {:error, :not_found}),
          handler :: (Ecto.Changeset.t() | {:error, :not_found} -> response())
        ) :: response()
  def process(params, validator, handler) do
    params
    |> validator.()
    |> handler.()
  end
end
