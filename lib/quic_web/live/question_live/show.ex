defmodule QuicWeb.QuestionLive.Show do
  use QuicWeb, :author_live_view

  alias Quic.Questions

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
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:current_path, "/quizzes/#{quiz_id}/question/#{question_id}")}
  end

  defp page_title(:show), do: "Show Question"
  defp page_title(:edit), do: "Edit Question"
end
