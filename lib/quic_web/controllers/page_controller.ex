defmodule QuicWeb.PageController do
  use QuicWeb, :controller

  def home(conn, _params) do
    if conn.assigns.current_author do
      conn |> redirect(to: ~p"/authors")
    else
      render(conn, :home, layout: false, page_title: "Welcome" )
    end
  end
end
