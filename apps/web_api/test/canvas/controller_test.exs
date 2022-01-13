defmodule AC.WebApi.Canvas.ControllerTest do
  use AC.WebApi.ConnCase

  alias AC.WebApi.Canvas
  alias AC.WebApi.Repo
  alias AC.WebApi.Test.Faker
  alias AC.WebApi.Fixtures

  setup do
    repo_config = [table_name: :controller_tests, name: ControllerTest]
    :ok = Application.put_env(:ac_web_api, :repo, repo_config)

    {:ok, _pid} = start_supervised({Repo, repo_config}, restart: :temporary)

    on_exit(fn ->
      repo_config[:table_name]
      |> to_string()
      |> File.exists?()
      |> if do
        :ok = File.rm(to_string(repo_config[:table_name]))
      end
    end)

    repo_config
  end

  describe "Controller.index/2" do
    test "returns 200 with empty list when no canvases", %{conn: conn} do
      conn = get(conn, "/canvases")
      assert [] = json_response(conn, 200)
    end

    test "returns 200 with list of items when canvases exist", %{conn: conn, name: repo} do
      {:ok, %{canvases: canvases}} = _setup_canvases(2, repo)

      [
        %{id: id_1, content: _, width: width_1, height: height_1},
        %{id: id_2, content: _, width: width_2, height: height_2}
      ] = canvases |> Enum.sort_by(&{&1.id})

      conn = get(conn, "/canvases")

      assert body = json_response(conn, 200)
      body = body |> Enum.sort_by(&{&1["id"]})

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

  describe "Controller.create/2" do
    test "returns 201 with canvas id for valid params", %{conn: conn} do
      request = Fixtures.new_request(:create_canvas)
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
    test "returns 204 when canvas id exists", %{conn: conn, name: repo} do
      {:ok, %{id_list: [id]}} = _setup_canvases(1, repo)
      conn = delete(conn, "/canvases/#{id}")
      assert conn.status == 204
      assert conn.resp_body == ""
    end

    test "returns 404 when canvas id doesn't exist", %{conn: conn} do
      uuid = Faker.generate(:uuid)
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
    test "returns 204 when canvas id exists and params are valid", %{conn: conn, name: repo} do
      {:ok, %{canvases: [%{id: id}]}} = _setup_canvases(1, repo, %{width: 10, height: 7})

      request =
        Fixtures.new_request(:draw_rectangle, %{
          id: id,
          coords: [3, 2],
          width: 5,
          height: 3,
          outline: "@",
          fill: nil
        })

      conn = put(conn, "/canvases/#{id}/draw_rectangle", request)
      assert conn.status == 204
      assert conn.resp_body == ""
    end

    test "returns 404 when canvas id doesn't exist", %{conn: conn} do
      uuid = Faker.generate(:uuid)
      conn = delete(conn, "/canvases/#{uuid}")
      assert conn.status == 404
      assert conn.resp_body == ""
    end

    test "returns 422 when canvas id is invalid", %{conn: conn} do
      conn = delete(conn, "/canvases/123")
      assert %{"id" => ["is invalid"]} = json_response(conn, 422)
    end

    test "returns 422 when x coord is out of bounds", %{conn: conn, name: repo} do
      {:ok, %{canvases: [%{id: id}]}} = _setup_canvases(1, repo, %{width: 10, height: 7})

      request =
        Fixtures.new_request(:draw_rectangle, %{
          id: id,
          coords: [10, 5],
          width: 5,
          height: 3,
          outline: "@",
          fill: nil
        })

      conn = put(conn, "/canvases/#{id}/draw_rectangle", request)

      assert %{"coords" => ["out of bounds: x must be between 0 and 9"]} =
               json_response(conn, 422)
    end

    test "returns 422 when y coord is out of bounds", %{conn: conn, name: repo} do
      {:ok, %{canvases: [%{id: id}]}} = _setup_canvases(1, repo, %{width: 10, height: 7})

      request =
        Fixtures.new_request(:draw_rectangle, %{
          id: id,
          coords: [9, 7],
          width: 5,
          height: 3,
          outline: "@",
          fill: nil
        })

      conn = put(conn, "/canvases/#{id}/draw_rectangle", request)

      assert %{"coords" => ["out of bounds: y must be between 0 and 6"]} =
               json_response(conn, 422)
    end

    test "returns 422 when coords is not a list of 2", %{conn: conn, name: repo} do
      {:ok, %{canvases: [%{id: id}]}} = _setup_canvases(1, repo, %{width: 10, height: 7})

      request =
        Fixtures.new_request(:draw_rectangle, %{
          id: id,
          coords: [3, 2, 5],
          width: 5,
          height: 3,
          outline: "@",
          fill: nil
        })

      conn = put(conn, "/canvases/#{id}/draw_rectangle", request)
      assert %{"coords" => ["should have 2 item(s)"]} = json_response(conn, 422)
    end
  end

  defp _setup_canvases(count, repo, overrides \\ %{}) do
    id_list =
      1..count
      |> Enum.map(fn _ -> Faker.generate(:uuid) end)

    canvases =
      id_list
      |> Enum.reduce([], fn id, acc ->
        %{"width" => width, "height" => height} = Fixtures.new_request(:create_canvas, overrides)
        canvas = Canvas.create(width, height, fn -> id end)
        Repo.insert_or_update(repo, id, canvas)
        [canvas | acc]
      end)
      |> Enum.reverse()

    {:ok, %{id_list: id_list, canvases: canvases}}
  end
end
