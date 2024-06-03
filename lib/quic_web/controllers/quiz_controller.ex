defmodule QuicWeb.QuizController do
  use QuicWeb, :controller

  alias Quic.Sessions

  def show(conn, %{"session_id" => session_id}) do
    # if conn.assigns.current_author do
    session = Sessions.get_session!(session_id)
    render(conn, :show, page_title: "Show Session Quiz", current_path: "/sessions/#{session_id}/quiz", quiz: session.quiz)
    # else
    #   conn |> redirect(to: ~p"/")
    # end
  end
end
