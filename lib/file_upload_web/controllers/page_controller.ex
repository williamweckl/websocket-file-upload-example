defmodule FileUploadWeb.PageController do
  use FileUploadWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
