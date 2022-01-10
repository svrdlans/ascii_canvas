defmodule AC.WebApi.Repo do
  use GenServer

  def start_link(opts) when is_list(opts),
    do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  @impl true
  def init(table_name: table_name) when is_atom(table_name) do
    {:ok, %{table_name: table_name}}
  end

  @spec insert_or_update(key :: any(), value :: any()) ::
          :ok | {:error, any()}
  def insert_or_update(key, value),
    do: GenServer.call(__MODULE__, {:insert_or_update, key, value})

  @spec get(key :: any()) :: nil | any() | {:error, any()}
  def get(key),
    do: GenServer.call(__MODULE__, {:get, key})

  @spec get_all() :: [any()] | {:error, any()}
  def get_all(),
    do: GenServer.call(__MODULE__, :get_all)

  @spec delete(key :: any()) :: :ok | {:error, any()}
  def delete(key),
    do: GenServer.call(__MODULE__, {:delete, key})

  @impl true
  def handle_call({:insert_or_update, key, value}, _from, %{table_name: table_name} = state) do
    result = _wrap_access(table_name, fn -> :dets.insert(table_name, {key, value}) end)
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
