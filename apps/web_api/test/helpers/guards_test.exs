defmodule AC.WebApi.Helpers.GuardsTest do
  use ExUnit.Case, async: true

  import AC.WebApi.Helpers.Guards

  describe "is_pos_integer/1" do
    test "verifies a value is integer greater than 0" do
      assert is_pos_integer(1)
      refute is_pos_integer(0)
      refute is_pos_integer(-1)
      refute is_pos_integer(1.0)
      refute is_pos_integer("1")
    end
  end

  describe "is_non_neg_integer/1" do
    test "verifies a value is integer greater or equal than 0" do
      assert is_non_neg_integer(1)
      assert is_non_neg_integer(0)
      refute is_non_neg_integer(-1)
      refute is_non_neg_integer(1.0)
      refute is_non_neg_integer("1")
    end
  end

  describe "is_valid_atom/1" do
    test "verifies a value is an atom and not nil, true, false" do
      assert is_valid_atom(:t)
      assert is_valid_atom(:"What-4")
      refute is_valid_atom(true)
      refute is_valid_atom(false)
      refute is_valid_atom(nil)
      refute is_valid_atom(1.0)
      refute is_valid_atom("1")
    end
  end
end
