defmodule AC.WebApi.CanvasTest do
  use ExUnit.Case, async: true

  alias AC.WebApi.Canvas

  describe "Canvas.create/3" do
    test "raises FunctionClauseError for width < 1" do
      assert_raise FunctionClauseError, fn ->
        Canvas.create(0, 5)
      end
    end

    test "raises FunctionClauseError for height < 1" do
      assert_raise FunctionClauseError, fn ->
        Canvas.create(5, 0)
      end
    end
  end
end
