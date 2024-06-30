defmodule QuicWeb.QuestionLive.Show do
  use QuicWeb, :author_live_view

  alias Quic.Quizzes
  alias Quic.Questions
  alias Quic.Parameters
  alias QuicWeb.QuicWebAux

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"quiz_id" => quiz_id, "question_id" => question_id}, _, socket) do
    if Quizzes.is_allowed_to_access?(quiz_id, socket.assigns.current_author) do
      {:noreply,
        socket
        |> assign(:quiz_id, quiz_id)
        |> assign(:isOwner, Quizzes.is_owner?(quiz_id, socket.assigns.current_author))
        |> assign(:question, Questions.get_question!(question_id))
        |> assign(:page_title, "Quiz - Show Question")
        |> assign(:current_path, "/quizzes/#{quiz_id}/question/#{question_id}")}
    else
      {:noreply, socket |> put_flash(:error, "You can't access questions of Quizzes not shared with you!") |> redirect(to: ~p"/quizzes")}
    end
  end

  @impl true
  def handle_event("clicked_edit", _params, socket) do
    {:noreply, socket |> redirect(to: ~p"/quizzes/#{socket.assigns.quiz_id}/edit-question/#{socket.assigns.question.id}")}
  end
end
