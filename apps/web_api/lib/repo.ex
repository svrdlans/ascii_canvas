defmodule AC.WebApi.Repo do
  @moduledoc """
  A repo process which allows the use of Erlang `:dets`.

  Since only on process is started in app supervison tree
  guarantees that all access to table file is sequential.

  Requires `:table_name` to be passed when calling `start_link/1`.
  """

  @behaviour AC.WebApi.RepoAPI
  use GenServer

  def start_link(opts) when is_list(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    opts
    |> Keyword.get(:table_name)
    |> case do
      nil ->
        {:stop, :table_name_missing}

      table_name when is_atom(table_name) ->
        {:ok, %{table_name: table_name}}

      _ ->
        {:stop, :table_name_invalid}
    end
  end

  @impl AC.WebApi.RepoAPI
  def insert_or_update(key, value),
    do: GenServer.call(__MODULE__, {:insert_or_update, key, value})

  @impl AC.WebApi.RepoAPI
  def exists?(key),
    do: GenServer.call(__MODULE__, {:exists?, key})

  @impl AC.WebApi.RepoAPI
  def get(key),
    do: GenServer.call(__MODULE__, {:get, key})

  @impl AC.WebApi.RepoAPI
  def get_all(),
    do: GenServer.call(__MODULE__, :get_all)

  @impl AC.WebApi.RepoAPI
  def delete(key),
    do: GenServer.call(__MODULE__, {:delete, key})

  @impl true
  def handle_call({:insert_or_update, key, value}, _from, %{table_name: table_name} = state) do
    result = _wrap_access(table_name, fn -> :dets.insert(table_name, {key, value}) end)
    {:reply, result, state}
  end

  @impl true
  def handle_call({:exists?, key}, _from, %{table_name: table_name} = state) do
    result = _wrap_access(table_name, fn -> :dets.member(table_name, key) end)
    {:reply, result, state}
  end

  @impl true
  def handle_call({:get, key}, _from, %{table_name: table_name} = state) do
    result =
      table_name
      |> _wrap_access(fn -> :dets.lookup(table_name, key) end)
      |> case do
        [] -> nil
        [{_, value} | _] -> value
      end

    {:reply, result, state}
  end

  @impl true
  def handle_call(:get_all, _from, %{table_name: table_name} = state) do
    result =
      _wrap_access(table_name, fn -> :dets.select(table_name, [{{:"$1", :"$2"}, [], [:"$2"]}]) end)

    {:reply, result, state}
  end

  @impl true
  def handle_call({:delete, key}, _from, %{table_name: table_name} = state) do
    result = _wrap_access(table_name, fn -> :dets.delete(table_name, key) end)
    {:reply, result, state}
  end

  @spec _open_table(table_name :: atom()) :: :ok
  defp _open_table(table_name) when is_atom(table_name) do
    {:ok, ^table_name} = :dets.open_file(table_name, type: :set)
    :ok
  end

  @spec _close_table(table_name :: atom()) :: :ok
  defp _close_table(table_name) when is_atom(table_name),
    do: :ok = :dets.close(table_name)

  @spec _wrap_access(table_name :: atom(), func :: (() -> :ok | [any()] | {:error, any()})) ::
          :ok | [any()] | {:error, any()}
  def _wrap_access(table_name, func) do
    :ok = _open_table(table_name)
    result = func.()
    :ok = _close_table(table_name)
    result
  end
end
