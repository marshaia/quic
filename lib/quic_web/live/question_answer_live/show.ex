defmodule QuicWeb.QuestionAnswerLive.Show do
  use QuicWeb, :live_view

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
     |> assign(:question_answer, Questions.get_question_answer!(id))}
  end

  defp page_title(:show), do: "Show Question answer"
  defp page_title(:edit), do: "Edit Question answer"
end
