defmodule AC.WebApi.Canvas.Requests.DrawRectangleTest do
  use ExUnit.Case, async: true

  alias AC.WebApi.Canvas.Requests.DrawRectangle
  alias AC.WebApi.Canvas
  alias AC.WebApi.Fixtures
  alias AC.WebApi.Test.Faker
  alias AC.WebApi.MockRepo

  import Mox

  setup do
    verify_on_exit!()

    [repo: Application.get_env(:ac_web_api, :repo_api)]
  end

  describe "DrawRectangle.validate/2" do
    test "returns validation error for invalid id", %{repo: repo} do
      request = Fixtures.new_request(:draw_rectangle, %{id: 234})

      assert %Ecto.Changeset{
               valid?: false,
               errors: [id: {"is invalid", [type: Ecto.UUID, validation: :cast]}]
             } = DrawRectangle.validate(request, repo)
    end

    test "returns id not_found when id doesn't exist", %{repo: repo} do
      %{"id" => id} = request = Fixtures.new_request(:draw_rectangle)

      MockRepo
      |> expect(:get, fn ^id -> nil end)

      assert %Ecto.Changeset{valid?: false, errors: [id: {"not found", []}]} =
               DrawRectangle.validate(request, repo)
    end

    test "returns validation error when required fields are not present", %{repo: repo} do
      assert %Ecto.Changeset{
               valid?: false,
               errors: [
                 id: {"can't be blank", [validation: :required]},
                 upper_left_corner: {"can't be blank", [validation: :required]},
                 width: {"can't be blank", [validation: :required]},
                 height: {"can't be blank", [validation: :required]}
               ]
             } = DrawRectangle.validate(%{}, repo)
    end

    test "returns validation error when upper_left_corner is a list of strings", %{repo: repo} do
      request = Fixtures.new_request(:draw_rectangle, %{upper_left_corner: ["a", "b"]})

      assert %Ecto.Changeset{
               valid?: false,
               errors: [
                 upper_left_corner: {"is invalid", [type: {:array, :integer}, validation: :cast]}
               ]
             } = DrawRectangle.validate(request, repo)
    end

    test "returns validation error when upper_left_corner isn't a list of 2", %{repo: repo} do
      request = Fixtures.new_request(:draw_rectangle, %{upper_left_corner: [1, 2, 4]})

      assert %Ecto.Changeset{
               valid?: false,
               errors: [
                 upper_left_corner:
                   {"should have %{count} item(s)",
                    [count: 2, validation: :length, kind: :is, type: :list]}
               ]
             } = DrawRectangle.validate(request, repo)
    end

    test "returns validation error when outline can't be cast to string", %{repo: repo} do
      request = Fixtures.new_request(:draw_rectangle, %{outline: 'a'})

      assert %Ecto.Changeset{
               valid?: false,
               errors: [outline: {"is invalid", [type: :string, validation: :cast]}]
             } = DrawRectangle.validate(request, repo)
    end

    test "returns validation error when outline has size > 1", %{repo: repo} do
      request = Fixtures.new_request(:draw_rectangle, %{outline: "ab"})

      assert %Ecto.Changeset{
               valid?: false,
               errors: [
                 outline:
                   {"should be %{count} character(s)",
                    [count: 1, validation: :length, kind: :is, type: :string]}
               ]
             } = DrawRectangle.validate(request, repo)
    end

    test "returns validation error when outline is not an ascii string", %{repo: repo} do
      request = Fixtures.new_request(:draw_rectangle, %{outline: <<255>>})

      assert %Ecto.Changeset{
               valid?: false,
               errors: [outline: {"must be a valid ASCII character", []}]
             } = DrawRectangle.validate(request, repo)
    end

    test "returns validation error when fill can't be cast to string", %{repo: repo} do
      request = Fixtures.new_request(:draw_rectangle, %{fill: 'a'})

      assert %Ecto.Changeset{
               valid?: false,
               errors: [fill: {"is invalid", [type: :string, validation: :cast]}]
             } = DrawRectangle.validate(request, repo)
    end

    test "returns validation error when fill has size > 1", %{repo: repo} do
      request = Fixtures.new_request(:draw_rectangle, %{fill: "ab"})

      assert %Ecto.Changeset{
               valid?: false,
               errors: [
                 fill:
                   {"should be %{count} character(s)",
                    [count: 1, validation: :length, kind: :is, type: :string]}
               ]
             } = DrawRectangle.validate(request, repo)
    end

    test "returns validation error when fill is not an ascii string", %{repo: repo} do
      request = Fixtures.new_request(:draw_rectangle, %{fill: <<255>>})

      assert %Ecto.Changeset{
               valid?: false,
               errors: [fill: {"must be a valid ASCII character", []}]
             } = DrawRectangle.validate(request, repo)
    end

    test "returns validation error when neither outline nor fill are present", %{repo: repo} do
      request = Fixtures.new_request(:draw_rectangle, %{outline: nil, fill: nil})

      assert %Ecto.Changeset{
               valid?: false,
               errors: [
                 outline: {"one of either these fields must be present: [:outline, :fill]", []}
               ]
             } = DrawRectangle.validate(request, repo)
    end

    test "returns validation error when x coord out of bounds", %{repo: repo} do
      {:ok, %{canvases: [%{id: id} = canvas]}} = _setup_canvases(1, %{width: 10, height: 5})

      request =
        Fixtures.new_request(:draw_rectangle, %{
          id: id,
          upper_left_corner: [10, 4],
          width: 1,
          height: 1
        })

      MockRepo
      |> expect(:get, fn ^id -> canvas end)

      assert %Ecto.Changeset{
               valid?: false,
               errors: [
                 upper_left_corner:
                   {"out of bounds: x must be between 0 and %{max_x}", [max_x: 9]}
               ]
             } = DrawRectangle.validate(request, repo)
    end

    test "returns validation error when y coord out of bounds", %{repo: repo} do
      {:ok, %{canvases: [%{id: id} = canvas]}} = _setup_canvases(1, %{width: 10, height: 5})

      request =
        Fixtures.new_request(:draw_rectangle, %{
          id: id,
          upper_left_corner: [9, 5],
          width: 1,
          height: 1
        })

      MockRepo
      |> expect(:get, fn ^id -> canvas end)

      assert %Ecto.Changeset{
               valid?: false,
               errors: [
                 upper_left_corner:
                   {"out of bounds: y must be between 0 and %{max_y}", [max_y: 4]}
               ]
             } = DrawRectangle.validate(request, repo)
    end

    test "returns validation error when [x, y] is out of bounds", %{repo: repo} do
      {:ok, %{canvases: [%{id: id} = canvas]}} = _setup_canvases(1, %{width: 10, height: 5})

      request =
        Fixtures.new_request(:draw_rectangle, %{
          id: id,
          upper_left_corner: [10, 5],
          width: 1,
          height: 1
        })

      MockRepo
      |> expect(:get, fn ^id -> canvas end)

      assert %Ecto.Changeset{
               valid?: false,
               errors: [
                 upper_left_corner:
                   {"out of bounds: x must be between 0 and %{max_x}, y between 0 and %{max_y}",
                    [max_x: 9, max_y: 4]}
               ]
             } = DrawRectangle.validate(request, repo)
    end

    test "returns validation error when width is out of bounds", %{repo: repo} do
      {:ok, %{canvases: [%{id: id} = canvas]}} = _setup_canvases(1, %{width: 10, height: 5})

      request =
        Fixtures.new_request(:draw_rectangle, %{
          id: id,
          upper_left_corner: [8, 4],
          width: 3,
          height: 2
        })

      MockRepo
      |> expect(:get, fn ^id -> canvas end)

      assert %Ecto.Changeset{
               valid?: false,
               errors: [
                 width:
                   {"must be less than or equal to %{number}",
                    [validation: :number, kind: :less_than_or_equal_to, number: 2]}
               ]
             } = DrawRectangle.validate(request, repo)
    end

    test "returns validation error when height is out of bounds", %{repo: repo} do
      {:ok, %{canvases: [%{id: id} = canvas]}} = _setup_canvases(1, %{width: 10, height: 5})

      request =
        Fixtures.new_request(:draw_rectangle, %{
          id: id,
          upper_left_corner: [8, 2],
          width: 2,
          height: 4
        })

      MockRepo
      |> expect(:get, fn ^id -> canvas end)

      assert %Ecto.Changeset{
               valid?: false,
               errors: [
                 height:
                   {"must be less than or equal to %{number}",
                    [validation: :number, kind: :less_than_or_equal_to, number: 3]}
               ]
             } = DrawRectangle.validate(request, repo)
    end

    test "returns valid changeset for valid data", %{repo: repo} do
      {:ok, %{canvases: [%{id: id} = canvas]}} = _setup_canvases(1, %{width: 10, height: 5})

      request =
        Fixtures.new_request(:draw_rectangle, %{
          id: id,
          upper_left_corner: [8, 2],
          width: 2,
          height: 3
        })

      MockRepo
      |> expect(:get, fn ^id -> canvas end)

      assert %Ecto.Changeset{valid?: true} = DrawRectangle.validate(request, repo)
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
