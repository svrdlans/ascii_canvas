defmodule AC.WebApi.Canvas.Handlers.Show do
  alias AC.WebApi.Canvas.Requests.Show
  alias AC.WebApi.Canvas
  import AC.WebApi.ErrorHelpers, only: [id_not_found?: 1]

  @spec handle(Ecto.Changeset.t(), module()) ::
          {:ok, Canvas.t()} | {:error, :not_found} | {:validation_error, Ecto.Changeset.t()}
  def handle(%Ecto.Changeset{valid?: false, errors: errors} = cs, _) do
    errors
    |> id_not_found?()
    |> if do
      {:error, :not_found}
    else
      {:validation_error, cs}
    end
  end

  def handle(%Ecto.Changeset{} = cs, _repo) do
    %{canvas: canvas} = Show.changes(cs)
    {:ok, Map.put(canvas, :content, Canvas.to_string(canvas))}
  end
end
