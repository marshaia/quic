defmodule QuicWeb.QuizLive.Show do
  use QuicWeb, :author_live_view

  alias Quic.Quizzes
  alias Quic.Questions

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:quiz, Quizzes.get_quiz!(id))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    question = Questions.get_question!(id)
    {:ok, _} = Questions.delete_question(question)
    Quizzes.update_quiz_points_when_question_deleted(socket.assigns.quiz.id, question.points)

    {:noreply, assign(socket, :quiz, Quizzes.get_quiz!(socket.assigns.quiz.id))}
  end

  defp page_title(:show), do: "Show Quiz"
  defp page_title(:edit), do: "Edit Quiz"
end
