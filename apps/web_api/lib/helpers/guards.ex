defmodule AC.WebApi.Helpers.Guards do
  defguard is_pos_integer(value) when is_integer(value) and value > 0
  defguard is_non_neg_integer(value) when is_integer(value) and value >= 0
  defguard is_valid_atom(value) when not is_nil(value) and is_atom(value)
end
