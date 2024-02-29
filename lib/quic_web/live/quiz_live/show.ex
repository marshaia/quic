defmodule QuicWeb.QuizLive.Show do
  use QuicWeb, :author_live_view

  alias Quic.Quizzes

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

  defp page_title(:show), do: "Show Quiz"
  defp page_title(:edit), do: "Edit Quiz"
end
