defmodule QuicWeb.QuizLive.Show do
  use QuicWeb, :author_live_view

  alias Quic.Quizzes
  alias Quic.Questions

  require Logger

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    if Quizzes.is_allowed_to_access?(id, socket.assigns.current_author) do
      {:noreply, socket
                |> assign(:page_title, page_title(socket.assigns.live_action))
                |> assign(:quiz, Quizzes.get_quiz!(id))
                |> assign(:current_path, ~p"/quizzes/#{id}")}
    else
      {:noreply, socket
            |> put_flash(:error, "You can only access Quizzes shared with/owned by you!")
            |> push_navigate(to: ~p"/quizzes/")}
    end

  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    question = Questions.get_question!(id)

    case Questions.delete_question(question) do
      {:ok, _} ->
        Quizzes.update_quiz_points(socket.assigns.quiz.id)

        {:noreply, socket
                  |> assign(:quiz, Quizzes.get_quiz!(socket.assigns.quiz.id))
                  |> put_flash(:info, "Question deleted successfully!")}

      {:error, _changeset} ->
        {:noreply, socket |> put_flash(:error, "Something went wrong :(")}
    end
  end

  @impl true
  def handle_event("duplicate", %{"id" => id}, socket) do
    question = Questions.get_question!(id)
    question_params = %{
      "title" => question.title,
      "description" => question.description,
      "points" => question.points,
      "type" => question.type
    }

    quiz_id = socket.assigns.quiz.id

    case Questions.create_question_with_quiz(question_params, quiz_id) do
      {:ok, _question} ->
        Quizzes.update_quiz_points(quiz_id)

        {:noreply, socket
                  |> assign(:quiz, Quizzes.get_quiz!(quiz_id))
                  |> put_flash(:info, "Question duplicated successfully!")}

      {:error, _changeset} ->
        {:noreply, socket |> put_flash(:error, "Something went wrong :(")}
    end
  end

  def isOwner?(quiz_id, author) do
    Quizzes.is_owner?(quiz_id, author)
  end

  defp page_title(:show), do: "Show Quiz"
  defp page_title(:edit), do: "Edit Quiz"
end
