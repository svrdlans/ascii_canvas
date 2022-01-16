defmodule AC.WebApi.Helpers.AppConfig do
  @moduledoc """
  Defines functions for centralised Application config access.
  """

  import AC.WebApi.Helpers.Guards, only: [is_valid_atom: 1]

  @spec get_table_name() :: {:ok, atom()} | {:error, :table_name_invalid}
  def get_table_name() do
    :ac_web_api
    |> Application.get_env(:table_name)
    |> case do
      table_name when is_valid_atom(table_name) -> {:ok, table_name}
      _ -> {:error, :table_name_invalid}
    end
  end
end
