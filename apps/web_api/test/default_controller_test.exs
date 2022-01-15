defmodule AC.WebApi.DefaultControllerTest do
  use AC.WebApi.ConnCase

  describe "DefaultController.any/2" do
    test "returns 404 for GET method and any route not in router", %{conn: conn} do
      conn = get(conn, "/hello")
      assert %{"message" => "Path not found"} = json_response(conn, 404)
    end

    test "returns 404 for POST method and any route not in router", %{conn: conn} do
      conn = post(conn, "/canvases/where")
      assert %{"message" => "Path not found"} = json_response(conn, 404)
    end

    test "returns 404 for PUT method and any route not in router", %{conn: conn} do
      conn = put(conn, "/canvases/12341/draw_circle")
      assert %{"message" => "Path not found"} = json_response(conn, 404)
    end

    test "returns 404 for DELETE method and any route not in router", %{conn: conn} do
      conn = delete(conn, "/canvases/to_delete/1")
      assert %{"message" => "Path not found"} = json_response(conn, 404)
    end
  end
end
