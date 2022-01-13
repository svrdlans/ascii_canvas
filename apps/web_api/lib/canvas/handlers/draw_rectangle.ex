defmodule AC.WebApi.Canvas.Handlers.DrawRectangle do
  alias AC.WebApi.Canvas.Requests.DrawRectangle
  alias AC.WebApi.Canvas.Draw
  alias AC.WebApi.Repo
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
    %{id: id} = params = cs |> DrawRectangle.changes() |> Map.from_struct()

    canvas =
      repo
      |> Repo.get(id)
      |> Draw.rectangle(params)

    :ok = Repo.insert_or_update(repo, id, canvas)
  end
end
