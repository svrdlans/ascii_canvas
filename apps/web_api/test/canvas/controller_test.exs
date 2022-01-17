defmodule AC.WebApi.Canvas.ControllerTest do
  use AC.WebApi.ConnCase

  alias AC.WebApi.Canvas
  alias AC.WebApi.Test.Faker
  alias AC.WebApi.Fixtures
  alias AC.WebApi.MockRepo

  import Mox

  setup :verify_on_exit!

  describe "Controller.index/2" do
    test "returns 200 with empty list when no canvases", %{conn: conn} do
      MockRepo
      |> expect(:get_all, fn -> [] end)

      conn = get(conn, "/canvases")
      assert [] = json_response(conn, 200)
    end

    test "returns 200 with list of items when canvases exist", %{conn: conn} do
      {:ok, %{canvases: canvases}} = _setup_canvases(2)

      [
        %{id: id_1, content: _, width: width_1, height: height_1},
        %{id: id_2, content: _, width: width_2, height: height_2}
      ] = canvases

      MockRepo
      |> expect(:get_all, fn -> canvases end)

      conn = get(conn, "/canvases")

      assert body = json_response(conn, 200)

      assert [
               %{
                 "id" => ^id_1,
                 "width" => ^width_1,
                 "height" => ^height_1
               },
               %{
                 "id" => ^id_2,
                 "width" => ^width_2,
                 "height" => ^height_2
               }
             ] = body
    end
  end

  describe "Controller.show/2" do
    setup do
      MockRepo
      |> allow(self(), AC.WebApi.Canvas.RequestHandler)

      :ok
    end

    test "returns 200 when canvas id exists", %{conn: conn} do
      {:ok, %{canvases: [%{id: id, width: width, height: height} = canvas]}} = _setup_canvases(1)

      MockRepo
      |> expect(:get, fn ^id -> canvas end)

      conn = get(conn, "/canvases/#{id}")
      assert %{"id" => ^id, "width" => ^width, "height" => ^height} = json_response(conn, 200)
    end

    test "returns 404 when canvas id doesn't exist", %{conn: conn} do
      uuid = Faker.generate(:uuid)

      MockRepo
      |> expect(:get, fn ^uuid -> nil end)

      conn = get(conn, "/canvases/#{uuid}")
      assert conn.status == 404
      assert conn.resp_body == ""
    end

    test "returns 422 when canvas id is invalid", %{conn: conn} do
      conn = get(conn, "/canvases/123")
      assert %{"id" => ["is invalid"]} = json_response(conn, 422)
    end

    test "returns 503 when processing raises an exception", %{conn: conn} do
      uuid = Faker.generate(:uuid)

      MockRepo
      |> expect(:get, fn ^uuid -> raise ArgumentError end)

      conn = get(conn, "/canvases/#{uuid}")
      assert %{"error" => "Internal error"} = json_response(conn, 503)
    end
  end

  describe "Controller.create/2" do
    setup do
      MockRepo
      |> allow(self(), AC.WebApi.Canvas.RequestHandler)

      :ok
    end

    test "returns 201 with canvas id for valid params", %{conn: conn} do
      request = Fixtures.new_request(:create_canvas)

      MockRepo
      |> expect(:insert_or_update, fn _key, _canvas -> :ok end)

      conn = post(conn, "/canvases", request)
      assert %{"id" => id} = json_response(conn, 201)
      assert byte_size(id) == 36
    end

    test "returns 422 with validation error text for invalid width", %{conn: conn} do
      request = Fixtures.new_request(:create_canvas, %{width: "test"})
      conn = post(conn, "/canvases", request)
      assert %{"width" => ["is invalid"]} = json_response(conn, 422)
    end

    test "returns 422 with validation error text for invalid height", %{conn: conn} do
      request = Fixtures.new_request(:create_canvas, %{height: 55})
      conn = post(conn, "/canvases", request)
      assert %{"height" => ["must be less than or equal to 50"]} = json_response(conn, 422)
    end
  end

  describe "Controller.delete/2" do
    setup do
      MockRepo
      |> allow(self(), AC.WebApi.Canvas.RequestHandler)

      :ok
    end

    test "returns 204 when canvas id exists", %{conn: conn} do
      {:ok, %{canvases: [%{id: id}]}} = _setup_canvases(1)

      MockRepo
      |> expect(:exists?, fn ^id -> true end)
      |> expect(:delete, fn ^id -> :ok end)

      conn = delete(conn, "/canvases/#{id}")
      assert conn.status == 204
      assert conn.resp_body == ""
    end

    test "returns 404 when canvas id doesn't exist", %{conn: conn} do
      uuid = Faker.generate(:uuid)

      MockRepo
      |> expect(:exists?, fn ^uuid -> false end)

      conn = delete(conn, "/canvases/#{uuid}")
      assert conn.status == 404
      assert conn.resp_body == ""
    end

    test "returns 422 when canvas id is invalid", %{conn: conn} do
      conn = delete(conn, "/canvases/123")
      assert %{"id" => ["is invalid"]} = json_response(conn, 422)
    end
  end

  describe "Controller.draw_rectangle/2" do
    setup do
      MockRepo
      |> allow(self(), AC.WebApi.Canvas.RequestHandler)

      :ok
    end

    test "returns 204 when canvas id exists and params are valid", %{conn: conn} do
      {:ok, %{canvases: [%{id: id} = canvas]}} = _setup_canvases(1, %{width: 10, height: 7})

      request =
        Fixtures.new_request(:draw_rectangle, %{
          id: id,
          upper_left_corner: [3, 2],
          width: 5,
          height: 3,
          outline: "@",
          fill: nil
        })

      MockRepo
      |> expect(:get, 2, fn ^id -> canvas end)
      |> expect(:insert_or_update, fn ^id, _canvas -> :ok end)

      conn = put(conn, "/canvases/#{id}/draw_rectangle", request)
      assert conn.status == 204
      assert conn.resp_body == ""
    end

    test "returns 404 when canvas id doesn't exist", %{conn: conn} do
      {:ok, %{canvases: [%{id: id}]}} = _setup_canvases(1, %{width: 10, height: 7})

      request =
        Fixtures.new_request(:draw_rectangle, %{
          id: id,
          upper_left_corner: [3, 2],
          width: 2,
          height: 3,
          outline: "@",
          fill: nil
        })

      MockRepo
      |> expect(:get, fn ^id -> nil end)

      conn = put(conn, "/canvases/#{id}/draw_rectangle", request)
      assert conn.status == 404
      assert conn.resp_body == ""
    end

    test "returns 422 when canvas id is invalid", %{conn: conn} do
      conn = put(conn, "/canvases/123/draw_rectangle")
      assert %{"id" => ["is invalid"]} = json_response(conn, 422)
    end

    test "returns 422 when upper_left_corner is not a list of 2", %{conn: conn} do
      %{"id" => id} =
        request = Fixtures.new_request(:draw_rectangle, %{upper_left_corner: [3, 2, 5]})

      conn = put(conn, "/canvases/#{id}/draw_rectangle", request)
      assert %{"upper_left_corner" => ["should have 2 item(s)"]} = json_response(conn, 422)
    end

    test "returns 422 when x coord is out of bounds", %{conn: conn} do
      {:ok, %{canvases: [%{id: id} = canvas]}} = _setup_canvases(1, %{width: 10, height: 7})

      request =
        Fixtures.new_request(:draw_rectangle, %{
          id: id,
          upper_left_corner: [10, 5],
          width: 5,
          height: 3,
          outline: "@",
          fill: nil
        })

      MockRepo
      |> expect(:get, fn ^id -> canvas end)

      conn = put(conn, "/canvases/#{id}/draw_rectangle", request)

      assert %{"upper_left_corner" => ["out of bounds: x must be between 0 and 9"]} =
               json_response(conn, 422)
    end

    test "returns 422 when y coord is out of bounds", %{conn: conn} do
      {:ok, %{canvases: [%{id: id} = canvas]}} = _setup_canvases(1, %{width: 10, height: 7})

      request =
        Fixtures.new_request(:draw_rectangle, %{
          id: id,
          upper_left_corner: [9, 7],
          width: 5,
          height: 3,
          outline: "@",
          fill: nil
        })

      MockRepo
      |> expect(:get, fn ^id -> canvas end)

      conn = put(conn, "/canvases/#{id}/draw_rectangle", request)

      assert %{"upper_left_corner" => ["out of bounds: y must be between 0 and 6"]} =
               json_response(conn, 422)
    end
  end

  describe "Controller.flood_fill/2" do
    setup do
      MockRepo
      |> allow(self(), AC.WebApi.Canvas.RequestHandler)

      :ok
    end

    test "returns 204 when canvas id exists and params are valid", %{conn: conn} do
      {:ok, %{canvases: [%{id: id} = canvas]}} = _setup_canvases(1, %{width: 10, height: 7})

      request = Fixtures.new_request(:flood_fill, %{id: id, start_coordinates: [3, 2], fill: "@"})

      MockRepo
      |> expect(:get, 2, fn ^id -> canvas end)
      |> expect(:insert_or_update, fn ^id, _canvas -> :ok end)

      conn = put(conn, "/canvases/#{id}/flood_fill", request)
      assert conn.status == 204
      assert conn.resp_body == ""
    end

    test "returns 404 when canvas id doesn't exist", %{conn: conn} do
      {:ok, %{canvases: [%{id: id}]}} = _setup_canvases(1, %{width: 10, height: 7})

      request = Fixtures.new_request(:flood_fill, %{id: id, start_coordinates: [3, 2], fill: "@"})

      MockRepo
      |> expect(:get, fn ^id -> nil end)

      conn = put(conn, "/canvases/#{id}/flood_fill", request)
      assert conn.status == 404
      assert conn.resp_body == ""
    end

    test "returns 422 when canvas id is invalid", %{conn: conn} do
      conn = put(conn, "/canvases/123/flood_fill")
      assert %{"id" => ["is invalid"]} = json_response(conn, 422)
    end

    test "returns 422 when start_coordinates is not a list of 2", %{conn: conn} do
      %{"id" => id} = request = Fixtures.new_request(:flood_fill, %{start_coordinates: [3, 2, 5]})

      conn = put(conn, "/canvases/#{id}/flood_fill", request)
      assert %{"start_coordinates" => ["should have 2 item(s)"]} = json_response(conn, 422)
    end

    test "returns 422 when x coord is out of bounds", %{conn: conn} do
      {:ok, %{canvases: [%{id: id} = canvas]}} = _setup_canvases(1, %{width: 10, height: 7})

      request =
        Fixtures.new_request(:flood_fill, %{id: id, start_coordinates: [10, 5], fill: "X"})

      MockRepo
      |> expect(:get, fn ^id -> canvas end)

      conn = put(conn, "/canvases/#{id}/flood_fill", request)

      assert %{"start_coordinates" => ["out of bounds: x must be between 0 and 9"]} =
               json_response(conn, 422)
    end

    test "returns 422 when y coord is out of bounds", %{conn: conn} do
      {:ok, %{canvases: [%{id: id} = canvas]}} = _setup_canvases(1, %{width: 10, height: 7})

      request = Fixtures.new_request(:flood_fill, %{id: id, start_coordinates: [9, 7], fill: "O"})

      MockRepo
      |> expect(:get, fn ^id -> canvas end)

      conn = put(conn, "/canvases/#{id}/flood_fill", request)

      assert %{"start_coordinates" => ["out of bounds: y must be between 0 and 6"]} =
               json_response(conn, 422)
    end
  end

  defp _setup_canvases(count, overrides \\ %{}) do
    canvases =
      1..count
      |> Enum.map(fn _ -> Faker.generate(:uuid) end)
      |> Enum.reduce([], fn id, acc ->
        %{"width" => width, "height" => height} = Fixtures.new_request(:create_canvas, overrides)
        canvas = Canvas.create(width, height, fn -> id end)
        [canvas | acc]
      end)
      |> Enum.reverse()

    {:ok, %{canvases: canvases}}
  end
end
