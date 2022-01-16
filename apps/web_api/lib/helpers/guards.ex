defmodule AC.WebApi.Helpers.Guards do
  defguard is_pos_integer(value) when is_integer(value) and value > 0
  defguard is_non_neg_integer(value) when is_integer(value) and value >= 0
  defguard is_valid_atom(value) when is_atom(value) and value not in [nil, true, false]
end
