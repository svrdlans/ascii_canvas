defmodule AC.WebApi.Canvas.Requests.FloodFillTest do
  use ExUnit.Case, async: true

  alias AC.WebApi.Canvas.Requests.FloodFill
  alias AC.WebApi.Canvas
  alias AC.WebApi.Fixtures
  alias AC.WebApi.Test.Faker
  alias AC.WebApi.MockRepo

  import Mox

  setup do
    verify_on_exit!()

    [repo: Application.get_env(:ac_web_api, :repo_api)]
  end

  describe "FloodFill.validate/2" do
    test "returns validation error for invalid id", %{repo: repo} do
      request = Fixtures.new_request(:flood_fill, %{id: 234})

      assert %Ecto.Changeset{
               valid?: false,
               errors: [id: {"is invalid", [type: Ecto.UUID, validation: :cast]}]
             } = FloodFill.validate(request, repo)
    end

    test "returns id not_found when id doesn't exist", %{repo: repo} do
      %{"id" => id} = request = Fixtures.new_request(:flood_fill)

      MockRepo
      |> expect(:get, fn ^id -> nil end)

      assert %Ecto.Changeset{valid?: false, errors: [id: {"not found", []}]} =
               FloodFill.validate(request, repo)
    end

    test "returns validation error when required fields are not present", %{repo: repo} do
      assert %Ecto.Changeset{
               valid?: false,
               errors: [
                 id: {"can't be blank", [validation: :required]},
                 start_coordinates: {"can't be blank", [validation: :required]},
                 fill: {"can't be blank", [validation: :required]}
               ]
             } = FloodFill.validate(%{}, repo)
    end

    test "returns validation error when start_coordinates is a list of strings", %{repo: repo} do
      request = Fixtures.new_request(:flood_fill, %{start_coordinates: ["a", "b"]})

      assert %Ecto.Changeset{
               valid?: false,
               errors: [
                 start_coordinates: {"is invalid", [type: {:array, :integer}, validation: :cast]}
               ]
             } = FloodFill.validate(request, repo)
    end

    test "returns validation error when start_coordinates isn't a list of 2", %{repo: repo} do
      request = Fixtures.new_request(:flood_fill, %{start_coordinates: [1, 2, 4]})

      assert %Ecto.Changeset{
               valid?: false,
               errors: [
                 start_coordinates:
                   {"should have %{count} item(s)",
                    [count: 2, validation: :length, kind: :is, type: :list]}
               ]
             } = FloodFill.validate(request, repo)
    end

    test "returns validation error when fill can't be cast to string", %{repo: repo} do
      request = Fixtures.new_request(:flood_fill, %{fill: 'a'})

      assert %Ecto.Changeset{
               valid?: false,
               errors: [fill: {"is invalid", [type: :string, validation: :cast]}]
             } = FloodFill.validate(request, repo)
    end

    test "returns validation error when fill has size > 1", %{repo: repo} do
      request = Fixtures.new_request(:flood_fill, %{fill: "ab"})

      assert %Ecto.Changeset{
               valid?: false,
               errors: [
                 fill:
                   {"should be %{count} character(s)",
                    [count: 1, validation: :length, kind: :is, type: :string]}
               ]
             } = FloodFill.validate(request, repo)
    end

    test "returns validation error when fill is not an ascii string", %{repo: repo} do
      request = Fixtures.new_request(:flood_fill, %{fill: <<255>>})

      assert %Ecto.Changeset{
               valid?: false,
               errors: [fill: {"must be a valid ASCII character", []}]
             } = FloodFill.validate(request, repo)
    end

    test "returns validation error when x coord out of bounds", %{repo: repo} do
      {:ok, %{canvases: [%{id: id} = canvas]}} = _setup_canvases(1, %{width: 10, height: 5})

      request = Fixtures.new_request(:flood_fill, %{id: id, start_coordinates: [10, 4]})

      MockRepo
      |> expect(:get, fn ^id -> canvas end)

      assert %Ecto.Changeset{
               valid?: false,
               errors: [
                 start_coordinates:
                   {"out of bounds: x must be between 0 and %{max_x}", [max_x: 9]}
               ]
             } = FloodFill.validate(request, repo)
    end

    test "returns validation error when y coord out of bounds", %{repo: repo} do
      {:ok, %{canvases: [%{id: id} = canvas]}} = _setup_canvases(1, %{width: 10, height: 5})

      request = Fixtures.new_request(:flood_fill, %{id: id, start_coordinates: [9, 5]})

      MockRepo
      |> expect(:get, fn ^id -> canvas end)

      assert %Ecto.Changeset{
               valid?: false,
               errors: [
                 start_coordinates:
                   {"out of bounds: y must be between 0 and %{max_y}", [max_y: 4]}
               ]
             } = FloodFill.validate(request, repo)
    end

    test "returns validation error when [x, y] is out of bounds", %{repo: repo} do
      {:ok, %{canvases: [%{id: id} = canvas]}} = _setup_canvases(1, %{width: 10, height: 5})

      request = Fixtures.new_request(:flood_fill, %{id: id, start_coordinates: [10, 5]})

      MockRepo
      |> expect(:get, fn ^id -> canvas end)

      assert %Ecto.Changeset{
               valid?: false,
               errors: [
                 start_coordinates:
                   {"out of bounds: x must be between 0 and %{max_x}, y between 0 and %{max_y}",
                    [max_x: 9, max_y: 4]}
               ]
             } = FloodFill.validate(request, repo)
    end

    test "returns validation error when start_coordinates already filled", %{repo: repo} do
      {:ok, %{canvases: [%{id: id, content: content} = canvas]}} =
        _setup_canvases(1, %{width: 10, height: 5})

      %{"start_coordinates" => [x, y]} =
        request = Fixtures.new_request(:flood_fill, %{id: id, start_coordinates: [7, 4]})

      MockRepo
      |> expect(:get, fn ^id -> %{canvas | content: put_in(content, [y, x], "O")} end)

      assert %Ecto.Changeset{valid?: false, errors: [start_coordinates: {"already filled", []}]} =
               FloodFill.validate(request, repo)
    end
  end

  defp _setup_canvases(count, overrides) do
    canvases =
      for _ <- 1..count do
        Faker.generate(:uuid)
      end
      |> Enum.reduce([], fn id, acc ->
        %{"width" => width, "height" => height} = Fixtures.new_request(:create_canvas, overrides)
        canvas = Canvas.create(width, height, fn -> id end)
        [canvas | acc]
      end)
      |> Enum.reverse()

    {:ok, %{canvases: canvases}}
  end
end
