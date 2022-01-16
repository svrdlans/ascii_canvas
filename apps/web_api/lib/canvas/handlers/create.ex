defmodule AC.WebApi.Canvas.Handlers.Create do
  alias AC.WebApi.Canvas.Requests.Create
  alias AC.WebApi.Canvas

  @spec handle(Ecto.Changeset.t(), module()) ::
          {:created, Canvas.uuid()} | {:validation_error, Ecto.Changeset.t()}
  def handle(%Ecto.Changeset{valid?: false} = cs, _),
    do: {:validation_error, cs}

  def handle(%Ecto.Changeset{} = cs, repo) do
    %{width: width, height: height} = Create.changes(cs)
    %Canvas{id: canvas_id} = canvas = Canvas.create(width, height)
    :ok = repo.insert_or_update(canvas_id, canvas)
    {:created, canvas_id}
  end
end
