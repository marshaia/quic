defmodule QuicWeb.QuizLive.Show do
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
    position = question.position
    quiz_id = socket.assigns.quiz.id

    case Questions.delete_question(question) do
      {:ok, _} ->
        Quizzes.update_quiz_questions_positions(quiz_id, position)
        Quizzes.update_quiz_points(quiz_id)

        {:noreply, socket
                  |> assign(:quiz, Quizzes.get_quiz!(quiz_id))
                  |> put_flash(:info, "Question deleted successfully!")}

      {:error, _changeset} ->
        {:noreply, socket |> put_flash(:error, "Something went wrong :(")}
    end
  end

  @impl true
  def handle_event("duplicate", %{"id" => id}, socket) do
    question = Questions.get_question!(id)
    question_params = %{
      "description" => question.description,
      "points" => question.points,
      "type" => question.type,
      "position" => Enum.count(socket.assigns.quiz.questions) + 1
    }

    quiz_id = socket.assigns.quiz.id

    case Questions.duplicate_question(question_params, quiz_id, question) do
      {:ok, _question} ->
        Quizzes.update_quiz_points(quiz_id)

        {:noreply, socket
                  |> assign(:quiz, Quizzes.get_quiz!(quiz_id))
                  |> put_flash(:info, "Question duplicated successfully!")}

      {:error, _changeset} ->
        {:noreply, socket |> put_flash(:error, "Something went wrong :(")}
    end
  end

  @impl true
  def handle_event("clicked_question", %{"id" => id}, socket) do
    {:noreply, socket |> redirect(to: ~p"/quizzes/#{socket.assigns.quiz.id}/question/#{id}")}
  end

  @impl true
  def handle_event("clicked_edit", %{"id" => id}, socket) do
    {:noreply, socket |> redirect(to: ~p"/quizzes/#{socket.assigns.quiz.id}/edit-question/#{id}")}
  end

  @impl true
  def handle_event("send_question_up", %{"id" => id}, socket) do
    quiz_id = socket.assigns.quiz.id
    Quizzes.send_quiz_question(:up, quiz_id, id, Enum.count(socket.assigns.quiz.questions))
    {:noreply, socket |> assign(:quiz, Quizzes.get_quiz!(quiz_id))}
  end

  @impl true
  def handle_event("send_question_down", %{"id" => id}, socket) do
    quiz_id = socket.assigns.quiz.id
    Quizzes.send_quiz_question(:down, quiz_id, id, Enum.count(socket.assigns.quiz.questions))
    {:noreply, socket |> assign(:quiz, Quizzes.get_quiz!(socket.assigns.quiz.id))}
  end



  def isOwner?(quiz_id, author) do
    Quizzes.is_owner?(quiz_id, author)
  end


  defp page_title(:show), do: "Show Quiz"
  defp page_title(:edit), do: "Edit Quiz"
  defp page_title(:new_question), do: "New Question"
end
