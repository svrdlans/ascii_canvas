defmodule AC.WebApi.Repo do
  @moduledoc """
  A repo process which allows the use of Erlang `:dets`.

  Since only on process is started in app supervison tree
  guarantees that all access to table file is sequential.

  Requires `:table_name` to be passed when calling `start_link/1`.
  """

  alias AC.WebApi.Canvas

  use GenServer

  def start_link(opts) when is_list(opts) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
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

  @spec insert_or_update(
          name :: module(),
          key :: Canvas.uuid() | any(),
          value :: Canvas.t() | any()
        ) ::
          :ok | {:error, any()}
  def insert_or_update(name, key, value),
    do: GenServer.call(name, {:insert_or_update, key, value})

  @spec exists?(name :: module(), key :: Canvas.uuid() | any()) :: boolean()
  def exists?(name, key),
    do: GenServer.call(name, {:exists?, key})

  @spec get(name :: module(), key :: Canvas.uuid() | any()) ::
          nil | Canvas.t() | any() | {:error, any()}
  def get(name, key),
    do: GenServer.call(name, {:get, key})

  @spec get_all(name :: module()) :: [Canvas.t() | any()] | {:error, any()}
  def get_all(name),
    do: GenServer.call(name, :get_all)

  @spec delete(name :: module(), key :: Canvas.t() | any()) :: :ok | {:error, any()}
  def delete(name, key),
    do: GenServer.call(name, {:delete, key})

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
