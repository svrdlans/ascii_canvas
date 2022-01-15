defmodule AC.WebApi.Canvas.Handlers.FloodFill do
  alias AC.WebApi.Canvas.Requests.FloodFill
  alias AC.WebApi.Canvas.Draw
  import AC.WebApi.ErrorHelpers, only: [id_not_found?: 1]

  @spec handle(Ecto.Changeset.t(), module()) ::
          :ok | {:error, :not_found} | {:validation_error, Ecto.Changeset.t()}
  def handle(%Ecto.Changeset{valid?: false, errors: errors} = cs, _) do
    errors
    |> id_not_found?()
    |> if do
      {:error, :not_found}
    else
      {:validation_error, cs}
    end
  end

  def handle(%Ecto.Changeset{} = cs, repo) do
    %{id: id} = params = cs |> FloodFill.changes() |> Map.from_struct()
    canvas = id |> repo.get() |> Draw.flood_fill(params)
    :ok = repo.insert_or_update(id, canvas)
  end
end
