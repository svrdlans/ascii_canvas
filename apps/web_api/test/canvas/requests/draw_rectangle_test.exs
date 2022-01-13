defmodule AC.WebApi.Canvas.Requests.DrawRectangleTest do
  use ExUnit.Case, async: true

  alias AC.WebApi.Canvas.Requests.DrawRectangle
  alias AC.WebApi.Canvas
  alias AC.WebApi.Fixtures
  alias AC.WebApi.Repo
  alias AC.WebApi.Test.Faker

  describe "DrawRectangle.validate/1" do
    setup :with_repo

    test "returns validation error for invalid id" do
      request = Fixtures.new_request(:draw_rectangle, %{id: 234})

      assert %Ecto.Changeset{
               valid?: false,
               errors: [id: {"is invalid", [type: Ecto.UUID, validation: :cast]}]
             } = DrawRectangle.validate(request)
    end

    test "returns id not_found when id doesn't exist" do
      request = Fixtures.new_request(:draw_rectangle)

      assert %Ecto.Changeset{valid?: false, errors: [id: {"not found", []}]} =
               DrawRectangle.validate(request)
    end

    test "returns validation error when required fields are not present" do
      assert %Ecto.Changeset{
               valid?: false,
               errors: [
                 id: {"can't be blank", [validation: :required]},
                 coords: {"can't be blank", [validation: :required]},
                 width: {"can't be blank", [validation: :required]},
                 height: {"can't be blank", [validation: :required]}
               ]
             } = DrawRectangle.validate(%{})
    end

    test "returns validation error when coords is a list of strings" do
      {:ok, %{canvases: [%{id: id}]}} = _setup_canvases(1, %{width: 10, height: 5})

      request =
        Fixtures.new_request(:draw_rectangle, %{id: id, coords: ["a", "b"], width: 1, height: 1})

      assert %Ecto.Changeset{
               valid?: false,
               errors: [coords: {"is invalid", [type: {:array, :integer}, validation: :cast]}]
             } = DrawRectangle.validate(request)
    end

    test "returns validation error when coords isn't a list of 2" do
      {:ok, %{canvases: [%{id: id}]}} = _setup_canvases(1, %{width: 10, height: 5})

      request =
        Fixtures.new_request(:draw_rectangle, %{id: id, coords: [1, 2, 4], width: 1, height: 1})

      assert %Ecto.Changeset{
               valid?: false,
               errors: [
                 coords:
                   {"should have %{count} item(s)",
                    [count: 2, validation: :length, kind: :is, type: :list]}
               ]
             } = DrawRectangle.validate(request)
    end

    test "returns validation error when x coord out of bounds" do
      {:ok, %{canvases: [%{id: id}]}} = _setup_canvases(1, %{width: 10, height: 5})

      request =
        Fixtures.new_request(:draw_rectangle, %{id: id, coords: [10, 5], width: 1, height: 1})

      assert %Ecto.Changeset{
               valid?: false,
               errors: [coords: {"x coordinate must be between 0 and %{max_x}", [max_x: 9]}]
             } = DrawRectangle.validate(request)
    end

    test "returns validation error when y coord out of bounds" do
      {:ok, %{canvases: [%{id: id}]}} = _setup_canvases(1, %{width: 10, height: 5})

      request =
        Fixtures.new_request(:draw_rectangle, %{id: id, coords: [9, 5], width: 1, height: 1})

      assert %Ecto.Changeset{
               valid?: false,
               errors: [coords: {"y coordinate must be between 0 and %{max_y}", [max_y: 4]}]
             } = DrawRectangle.validate(request)
    end
  end

  def with_repo(_c) do
    table_name = Application.get_env(:ac_web_api, :table_name)
    {:ok, _pid} = Repo.start_link(table_name: table_name)

    on_exit(fn ->
      to_string(table_name)
      |> File.exists?()
      |> if do
        :ok = File.rm(to_string(table_name))
      else
        :ok
      end
    end)

    [table_name: table_name]
  end

  defp _setup_canvases(count, overrides) do
    id_list =
      1..count
      |> Enum.map(fn _ -> Faker.generate(:uuid) end)

    canvases =
      id_list
      |> Enum.reduce([], fn id, acc ->
        %{"width" => width, "height" => height} = Fixtures.new_request(:create_canvas, overrides)
        canvas = Canvas.create(width, height, fn -> id end)
        Repo.insert_or_update(id, canvas)
        [canvas | acc]
      end)
      |> Enum.reverse()

    {:ok, %{id_list: id_list, canvases: canvases}}
  end
end
