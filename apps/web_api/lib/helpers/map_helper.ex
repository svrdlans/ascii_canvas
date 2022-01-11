defmodule AC.WebApi.Helpers.MapHelper do
  @spec from_struct([%{__struct__: module()} | %{atom() => any()}]) :: [%{atom() => any()}]
  def from_struct(list) when is_list(list) do
    list
    |> Enum.map(fn
      %_{} = st -> Map.from_struct(st)
      %{} = map -> map
    end)
  end
end
