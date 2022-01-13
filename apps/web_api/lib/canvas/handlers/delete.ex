defmodule AC.WebApi.Canvas.Handlers.Delete do
  alias AC.WebApi.Canvas.Requests.Delete
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
    %{id: id} = Delete.changes(cs)
    :ok = Repo.delete(repo, id)
  end
end
