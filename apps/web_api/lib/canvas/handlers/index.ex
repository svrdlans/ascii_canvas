defmodule AC.WebApi.Canvas.Handlers.Index do
  alias AC.WebApi.Canvas
  alias AC.WebApi.Repo

  @spec handle(repo :: module()) :: {:ok, [Canvas.t()]}
  def handle(repo),
    do: {:ok, Repo.get_all(repo)}
end
