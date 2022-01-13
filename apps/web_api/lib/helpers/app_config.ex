defmodule AC.WebApi.Helpers.AppConfig do
  @moduledoc """
  Defines functions for centralised Application config access.
  """

  import AC.WebApi.Helpers.Guards, only: [is_valid_atom: 1]

  @default_repo AC.WebApi.Repo

  @spec get_repo_config() ::
          {:ok, keyword()} | {:error, :table_name_invalid} | {:error, :name_invalid}
  def get_repo_config() do
    repo_config = :ac_web_api |> Application.get_env(:repo)
    table_name = Keyword.get(repo_config, :table_name)
    name = Keyword.get(repo_config, :name) || @default_repo

    case {table_name, name} do
      {table_name, name} when is_valid_atom(table_name) and is_valid_atom(name) ->
        {:ok, [table_name: table_name, name: name]}

      {table_name, _} when is_valid_atom(table_name) ->
        {:error, :name_invalid}

      {_, name} when is_valid_atom(name) ->
        {:error, :table_name_invalid}

      {_, _} ->
        {:error, :table_name_invalid}
    end
  end

  @spec get_repo_table_name() :: {:ok, atom()} | {:error, :table_name_invalid}
  def get_repo_table_name() do
    :ac_web_api
    |> Application.get_env(:repo)
    |> Keyword.get(:table_name)
    |> case do
      table_name when is_valid_atom(table_name) -> {:ok, table_name}
      _ -> {:error, :table_name_invalid}
    end
  end

  @spec get_repo_name() :: {:ok, atom()} | {:error, :name_invalid}
  def get_repo_name() do
    :ac_web_api
    |> Application.get_env(:repo)
    |> Keyword.get(:name)
    |> case do
      name when is_valid_atom(name) -> {:ok, name}
      nil -> {:ok, @default_repo}
      _ -> {:error, :name_invalid}
    end
  end
end
