defmodule QuicWeb.QuestionsController do
  use QuicWeb, :controller

  alias Quic.Questions

  def show(conn, %{"quiz_id" => quiz_id, "question_id" => question_id}) do
    question = Questions.get_question!(question_id)
    conn
    |> put_layout(html: :author)
    |> render(:show, page_title: "Quiz Question", quiz_id: quiz_id, question: question, current_path: "/quizzes/#{quiz_id}/#{question_id}")
  end
end
