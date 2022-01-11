defmodule AC.WebApi.Canvas.Handlers.Create do
  alias AC.WebApi.Canvas.Requests.Create
  alias AC.WebApi.Canvas
  alias AC.WebApi.Repo

  @spec handle(Ecto.Changeset.t()) ::
          {:created, Canvas.uuid()} | {:validation_error, Ecto.Changeset.t()}
  def handle(%Ecto.Changeset{valid?: false} = cs),
    do: {:validation_error, cs}

  def handle(%Ecto.Changeset{} = cs) do
    %{width: width, height: height} = Create.changes(cs)
    %Canvas{id: canvas_id} = canvas = Canvas.create(width, height)
    :ok = Repo.insert_or_update(canvas_id, canvas)
    {:created, canvas_id}
  end
end
