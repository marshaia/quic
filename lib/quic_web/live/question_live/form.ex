defmodule QuicWeb.QuestionLive.Form do
  use QuicWeb, :author_live_view

  alias Quic.Quizzes
  alias Quic.Questions
  alias Quic.Questions.Question


  @impl true
  def mount(%{"question_id" => question_id, "quiz_id" => quiz_id} = _params, _session, socket) do
    question = Questions.get_question!(question_id)

    if Quizzes.is_owner?(quiz_id, socket.assigns.current_author) do
      changeset = Questions.change_question(question)
      {:ok, socket
          |> assign(:quiz_id, quiz_id)
          |> assign(:question, question)
          |> assign(:changeset, changeset)
          |> assign(:page_title, "Quiz - Edit Question")}
    else
      {:ok, socket
            |> put_flash(:error, "You can only edit your own quizzes' questions!")
            |> push_navigate(to: ~p"/quizzes/#{quiz_id}/question/#{question.id}")}
    end
  end


  @impl true
  def mount(_params = %{"quiz_id" => quiz_id}, _session, socket) do
    question = Questions.change_question(%Question{}) |> Ecto.Changeset.put_assoc(:quiz, Quizzes.get_quiz!(quiz_id))

    {:ok, socket
          |> assign(:quiz_id, quiz_id)
          |> assign(:changeset, question)
          |> assign(:page_title, "Quiz - New Question")}
  end


  @impl true
  def handle_event("validate", %{"question" => question_params}, socket) do
    changeset =
      %Question{}
      |> Questions.change_question(question_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("save", %{"question" => question_params}, socket) do
    if socket.assigns[:question] do
      save_question(socket, :edit, question_params)
    else
      save_question(socket, :new, question_params)
    end
  end


  defp save_question(socket, :edit, question_params) do
    quiz_id = socket.assigns.quiz_id

    case Questions.update_question(socket.assigns.question, question_params) do
      {:ok, question} ->      # notify_parent({:saved, question})

        {:noreply,
         socket
         |> put_flash(:info, "Question updated successfully")
         |> push_navigate(to: ~p"/quizzes/#{quiz_id}/question/#{question.id}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket
                  |> put_flash(:error, "Error updating question")
                  |> assign(changeset: changeset)}
    end
  end

  defp save_question(socket, :new, question_params) do
    quiz_id = socket.assigns.quiz_id

    case Questions.create_question_with_quiz(question_params, quiz_id) do
      {:ok, question} ->
        # notify_parent({:saved, question})

        {:noreply,
         socket
         |> put_flash(:info, "Question created successfully")
         |> push_navigate(to: ~p"/quizzes/#{quiz_id}/question/#{question.id}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

end
