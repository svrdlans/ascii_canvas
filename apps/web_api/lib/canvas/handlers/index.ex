defmodule AC.WebApi.Canvas.Handlers.Index do
  alias AC.WebApi.Canvas
  alias AC.WebApi.Repo

  @spec handle(repo :: module()) :: {:ok, [Canvas.t()]}
  def handle(repo) do
    canvases =
      repo
      |> Repo.get_all()
      |> Enum.map(&Map.put(&1, :content, Canvas.to_string(&1)))

    {:ok, canvases}
  end
end
