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
          validator ::
            (map -> Ecto.Changeset.t() | {:error, :not_found})
            | (map, module() -> Ecto.Changeset.t() | {:error, :not_found}),
          handler ::
            (Ecto.Changeset.t() | {:error, :not_found} -> response())
            | (Ecto.Changeset.t(), module() | {:error, :not_found} -> response()),
          repo :: :none | module()
        ) :: response()
  def process(params, validator, handler, repo \\ :none)

  def process(params, validator, handler, :none) do
    params
    |> validator.()
    |> handler.()
  end

  def process(params, validator, handler, repo) do
    params
    |> validator.(repo)
    |> handler.(repo)
  end
end
