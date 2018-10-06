defmodule Kubeojo.PageController do
  use Kubeojo.Web, :controller

  @spec index(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def index(conn, _params) do
    render conn, "index.html"
  end
end
