defmodule QuicWeb.QuestionLive.Show do
  use QuicWeb, :author_live_view

  alias Quic.Questions
  alias QuicWeb.QuicWebAux

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"quiz_id" => quiz_id, "question_id" => question_id}, _, socket) do
    {:noreply,
     socket
     |> assign(:quiz_id, quiz_id)
     |> assign(:question, Questions.get_question!(question_id))
     |> assign(:page_title, "Quiz - Show Question")
     |> assign(:current_path, "/quizzes/#{quiz_id}/question/#{question_id}")}
  end

  @impl true
  def handle_event("clicked_edit", _params, socket) do
    {:noreply, socket |> redirect(to: ~p"/quizzes/#{socket.assigns.quiz_id}/edit-question/#{socket.assigns.question.id}")}
  end
end
