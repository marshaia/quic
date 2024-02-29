defmodule QuicWeb.AuthorController do
  use QuicWeb, :controller

  def home(conn, _params) do
    conn
    |> put_layout(html: :author)
    |> render(:home, page_title: "Home")
  end
end
