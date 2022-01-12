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
      assert conn.status == 200
      assert conn.resp_body == "[]"
    end

    test "returns 200 with list of items when canvases exist", %{conn: conn} do
      :ok = _setup_canvases(2)

      conn = get(conn, "/canvases")
      assert conn.status == 200
      assert conn.resp_body |> byte_size() |> Kernel.>(100)
    end
  end

  describe "Controller.create/2" do
    test "returns 201 with canvas id for valid params", %{conn: conn} do
      request = Fixtures.new_request(:create_canvas)
      conn = post(conn, "/canvases", request)
      assert conn.status == 201
      assert %{"id" => id} = conn.resp_body |> Jason.decode!()
      assert byte_size(id) == 36
    end

    test "returns 422 with validation error text for invalid width", %{conn: conn} do
      request = Fixtures.new_request(:create_canvas, %{width: "test"})
      conn = post(conn, "/canvases", request)
      assert conn.status == 422
      assert conn.resp_body == "{\"width\":[\"is invalid\"]}"
    end

    test "returns 422 with validation error text for invalid height", %{conn: conn} do
      request = Fixtures.new_request(:create_canvas, %{height: 55})
      conn = post(conn, "/canvases", request)
      assert conn.status == 422
      assert conn.resp_body == "{\"height\":[\"must be less than or equal to 50\"]}"
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

    :ok
  end
end
