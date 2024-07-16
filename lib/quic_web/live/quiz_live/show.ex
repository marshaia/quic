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
        case Quizzes.update_quiz_questions_positions(quiz_id, position) do
          {:ok, _} ->
            case Quizzes.update_quiz_points(quiz_id) do
              {:ok, _} ->
                {:noreply, socket
                  |> assign(:quiz, Quizzes.get_quiz!(quiz_id))
                  |> put_flash(:info, "Question deleted successfully!")}

              {:error, _} -> {:noreply, socket |> put_flash(:error, "Something went wrong :(")}
            end
          {:error, _} -> {:noreply, socket |> put_flash(:error, "Something went wrong :(")}
        end

      {:error, _changeset} ->
        {:noreply, socket |> put_flash(:error, "Something went wrong :(")}
    end
  end

  @impl true
  def handle_event("duplicate_quiz", _params, socket) do
    quiz = socket.assigns.quiz
    quiz_params = %{
      "name" => quiz.name,
      "description" => quiz.description,
      "total_points" => quiz.total_points,
      "public" => quiz.public,
    }

    case Quizzes.duplicate_quiz(quiz_params, quiz.id, socket.assigns.current_author.id) do
      {:ok, {:ok, new_quiz}} -> {:noreply, socket |> put_flash(:info, "Quiz duplicated successfully! Sending you to its page...") |> redirect(to: ~p"/quizzes/#{new_quiz.id}")}
      _ -> {:noreply, socket |> put_flash(:error, "Something went wrong :(")}
    end
  end

  @impl true
  def handle_event("duplicate_question", %{"id" => id}, socket) do
    question = Questions.get_question!(id)
    question_params = %{
      "description" => question.description,
      "points" => question.points,
      "type" => question.type,
      "position" => Enum.count(socket.assigns.quiz.questions) + 1
    }

    quiz_id = socket.assigns.quiz.id

    case Questions.duplicate_question(question_params, quiz_id, question) do
      {:ok, _} ->
        case Quizzes.update_quiz_points(quiz_id) do
          {:ok, _} ->
            {:noreply, socket
              |> assign(:quiz, Quizzes.get_quiz!(quiz_id))
              |> put_flash(:info, "Question duplicated successfully!")}
          {:error, _} ->
            {:noreply, socket |> put_flash(:error, "Something went wrong :(")}
        end

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
    case Quizzes.send_quiz_question(:up, quiz_id, id, Enum.count(socket.assigns.quiz.questions)) do
      {:ok, _} -> {:noreply, socket |> assign(:quiz, Quizzes.get_quiz!(quiz_id))}
      {:error, _} -> {:noreply, socket |> put_flash(:error, "Something went wrong :(")}
    end
  end

  @impl true
  def handle_event("send_question_down", %{"id" => id}, socket) do
    quiz_id = socket.assigns.quiz.id
    case Quizzes.send_quiz_question(:down, quiz_id, id, Enum.count(socket.assigns.quiz.questions)) do
      {:ok, _} -> {:noreply, socket |> assign(:quiz, Quizzes.get_quiz!(quiz_id))}
      {:error, _} -> {:noreply, socket |> put_flash(:error, "Something went wrong :(")}
    end
  end

  @impl true
  def handle_event("clicked_quiz_author", _params, socket) do
    {:noreply, socket |> redirect(to: ~p"/authors/profile/#{socket.assigns.quiz.author.id}")}
  end


  def isOwner?(quiz_id, author) do
    Quizzes.is_owner?(quiz_id, author)
  end


  defp page_title(:show), do: "Show Quiz"
  defp page_title(:edit), do: "Edit Quiz"
  defp page_title(:new_question), do: "New Question"
end
