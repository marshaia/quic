defmodule QuicWeb.QuestionAnswerLive.Show do
  use QuicWeb, :live_view

  alias Quic.Questions

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"quiz_id" => quiz_id, "question_id" => question_id, "answer_id" => answer_id}, _, socket) do

    {:noreply,
     socket
     |> assign(:answer, Questions.get_question_answer!(answer_id))
     |> assign(:question_id, question_id)
     |> assign(:quiz_id, quiz_id)
     |> assign(:back, "/quizzes/#{quiz_id}/question/#{question_id}")
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:current_path, "/quizzes/#{quiz_id}/question/#{question_id}/answer/#{answer_id}")}
  end

  defp page_title(:show), do: "Show Question answer"
  defp page_title(:edit), do: "Edit Question answer"
end
