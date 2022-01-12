defmodule AC.WebApi.Canvas.ControllerTest do
  use AC.WebApi.ConnCase

  alias AC.WebApi.Canvas
  alias AC.WebApi.Repo
  alias AC.WebApi.Test.Faker
  alias AC.WebApi.Fixtures

  setup do
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

  describe "Controller.index/2" do
    test "returns 200 with empty list when no canvases", %{conn: conn} do
      conn = get(conn, "/canvases")
      assert [] = json_response(conn, 200)
    end

    test "returns 200 with list of items when canvases exist", %{conn: conn} do
      {:ok, ids} = _setup_canvases(2)
      [id_1, id_2] = ids |> Enum.sort()
      conn = get(conn, "/canvases")

      assert body = json_response(conn, 200)
      body = body |> Enum.sort_by(&{&1["id"]})

      assert [
               %{"id" => ^id_1, "content" => _, "width" => _, "height" => _},
               %{"id" => ^id_2, "content" => _, "width" => _, "height" => _}
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
    test "returns 204 when canvas id exists", %{conn: conn} do
      {:ok, [id]} = _setup_canvases(1)
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

  defp _setup_canvases(count) do
    id_list =
      1..count
      |> Enum.map(fn _ -> Faker.generate(:uuid) end)

    id_list
    |> Enum.map(fn id ->
      %{"width" => width, "height" => height} = Fixtures.new_request(:create_canvas)
      canvas = Canvas.create(width, height, fn -> id end)
      Repo.insert_or_update(id, canvas)
    end)

    {:ok, id_list}
  end
end
