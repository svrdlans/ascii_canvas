defmodule AC.WebApi.RepoAPI do
  @moduledoc """
  Defines repo callbacks.
  """

  alias AC.WebApi.Canvas

  @callback insert_or_update(key :: Canvas.uuid() | any(), value :: Canvas.t() | any()) ::
              :ok | {:error, any()}

  @callback exists?(key :: Canvas.uuid() | any()) :: boolean()

  @callback get(key :: Canvas.uuid() | any()) :: nil | Canvas.t() | any() | {:error, any()}

  @callback get_all() :: [Canvas.t() | any()] | {:error, any()}

  @callback delete(key :: Canvas.t() | any()) :: :ok | {:error, any()}

  def insert_or_update(key, value), do: _repo().insert_or_update(key, value)
  def exists?(key), do: _repo().exists?(key)
  def get(key), do: _repo().get(key)
  def get_all(), do: _repo().get_all()
  def delete(key), do: _repo().delete(key)
  defp _repo, do: Application.get_env(:ac_web_api, :repo_api, AC.WebApi.Repo)
end
