defmodule AC.WebApi.Canvas.Handlers.Delete do
  alias AC.WebApi.Canvas.Requests.Delete
  alias AC.WebApi.Repo

  @spec handle(Ecto.Changeset.t()) :: :ok | {:validation_error, Ecto.Changeset.t()}
  def handle(%Ecto.Changeset{valid?: false} = cs),
    do: {:validation_error, cs}

  def handle(%Ecto.Changeset{} = cs) do
    %{id: id} = Delete.changes(cs)

    id
    |> Repo.exists?()
    |> if do
      :ok = Repo.delete(id)
    else
      {:error, :not_found}
    end
  end
end
