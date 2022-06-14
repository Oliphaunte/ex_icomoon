defmodule KuratorsWeb.PageController do
  use KuratorsWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
