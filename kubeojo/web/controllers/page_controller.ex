defmodule Kubeojo.PageController do
  use Kubeojo.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
