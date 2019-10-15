defmodule Kubeojo.PageControllerTest do
  use Kubeojo.ConnCase

  describe "GET /" do
    test "It renders successfully if given no params", %{conn: conn} do
      conn = get(conn, "/")
      assert conn.status == 200
    end
  end
end
