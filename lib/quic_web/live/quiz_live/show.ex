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
    if Quizzes.is_allowed_to_access?(id, socket.assigns.current_author) do
      {:noreply, socket
                |> assign(:page_title, page_title(socket.assigns.live_action))
                |> assign(:quiz, Quizzes.get_quiz!(id))}
    else
      {:noreply, socket
            |> put_flash(:error, "You can only access Quizzes shared with/owned by you!")
            |> push_navigate(to: ~p"/quizzes/")}
    end

  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    question = Questions.get_question!(id)
    {:ok, _} = Questions.delete_question(question)
    Quizzes.update_quiz_points(socket.assigns.quiz.id)

    {:noreply, assign(socket, :quiz, Quizzes.get_quiz!(socket.assigns.quiz.id))}
  end

  def isOwner?(quiz_id, author) do
    Quizzes.is_owner?(quiz_id, author)
  end

  defp page_title(:show), do: "Show Quiz"
  defp page_title(:edit), do: "Edit Quiz"
end
