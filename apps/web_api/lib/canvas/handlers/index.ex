defmodule AC.WebApi.Canvas.Handlers.Index do
  alias AC.WebApi.Canvas
  alias AC.WebApi.Repo

  @spec handle() :: {:ok, [Canvas.t()]}
  def handle(),
    do: {:ok, Repo.get_all()}
end
