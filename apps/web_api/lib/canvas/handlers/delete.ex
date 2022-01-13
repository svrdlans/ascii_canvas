defmodule AC.WebApi.Canvas.Handlers.Delete do
  alias AC.WebApi.Canvas.Requests.Delete
  import AC.WebApi.ErrorHelpers, only: [id_not_found?: 1]
  alias AC.WebApi.Repo

  @spec handle(Ecto.Changeset.t()) ::
          :ok | {:error, :not_found} | {:validation_error, Ecto.Changeset.t()}
  def handle(%Ecto.Changeset{valid?: false, errors: errors} = cs) do
    errors
    |> id_not_found?()
    |> if do
      {:error, :not_found}
    else
      {:validation_error, cs}
    end
  end

  def handle(%Ecto.Changeset{} = cs) do
    %{id: id} = Delete.changes(cs)
    :ok = Repo.delete(id)
  end
end
