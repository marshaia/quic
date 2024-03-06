defmodule QuicWeb.QuestionLive.Form do
  use QuicWeb, :author_live_view

  alias Quic.Quizzes
  alias Quic.Questions


  def mount(%{"question_id" => question_id, "quiz_id" => quiz_id} = _params, _session, socket) do
    question = Questions.get_question!(question_id)

    if Quizzes.is_owner?(quiz_id, socket.assigns.current_author) do
      {:ok, socket
          |> assign(:quiz_id, quiz_id)
          |> assign(:question, question)
          |> assign(:page_title, "Quiz - Edit Question")}
    else
      {:ok, socket
            |> put_flash(:error, "You can only edit your own quizzes's questions!")
            |> redirect(to: ~p"/quizzes/#{quiz_id}/question/#{question.id}")}
    end

  end

  def mount(_params = %{"quiz_id" => quiz_id}, _session, socket) do
    {:ok, socket |> assign(:quiz_id, quiz_id) |> assign(:page_title, "Quiz - New Question")}
  end



end
