defmodule Butler.PageController do
  use Butler.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
