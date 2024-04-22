defmodule QuicWeb.QuestionAnswerLive.Form do

  use QuicWeb, :author_live_view

  alias Quic.Questions
  alias Quic.Questions.QuestionAnswer

  require Logger

  @impl true
  def mount(%{"quiz_id" => quiz_id, "question_id" => question_id, "answer_id" => answer_id} = _params, _session, socket) do
    answer = Questions.get_question_answer!(answer_id)

    if Questions.answer_belongs_to_question?(question_id, answer_id) do
      changeset = Questions.change_question_answer(answer)
      {:ok, socket
          |> assign(:quiz_id, quiz_id)
          |> assign(:question_id, question_id)
          |> assign(:action, :edit)
          |> assign(:answer, answer)
          |> assign(:changeset, changeset)
          |> assign(:page_title, "Edit Answer")
          |> assign(:current_path, "/quizzes/#{quiz_id}/question/#{question_id}/answer/#{answer_id}/edit")}
    else
      {:ok, socket
            |> put_flash(:error, "You can only edit your own quizzes' questions!")
            |> push_navigate(to: ~p"/quizzes/#{quiz_id}/question/#{question_id}")}
    end
  end


  @impl true
  def mount(%{"quiz_id" => quiz_id, "question_id" => question_id} = _params, _session, socket) do
    changeset = Questions.change_question_answer(%QuestionAnswer{})

    {:ok, socket
        |> assign(:quiz_id, quiz_id)
        |> assign(:question_id, question_id)
        |> assign(:action, :new)
        |> assign(:changeset, changeset)
        |> assign(:page_title, "Edit Answer")
        |> assign(:current_path, "/quizzes/#{quiz_id}/question/#{question_id}/answer/new")}
  end

  @impl true
  def handle_event("validate", %{"question_answer" => answer_params}, socket) do
    changeset =
      %QuestionAnswer{}
      |> Questions.change_question_answer(answer_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"question_answer" => question_answer_params}, socket) do
    save_question_answer(socket, socket.assigns.action, question_answer_params)
  end

  defp save_question_answer(socket, :edit, answer_params) do
    case Questions.update_question_answer(socket.assigns.answer, answer_params) do
      {:ok, _question_answer} ->
        #notify_parent({:saved, question_answer})

        {:noreply,
         socket
         |> put_flash(:info, "Question answer updated successfully")
         |> redirect(to: "/quizzes/#{socket.assigns.quiz_id}/question/#{socket.assigns.question_id}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_question_answer(socket, :new, answer_params) do
    case Questions.create_answer_with_question(answer_params, socket.assigns.question_id) do
      {:ok, _question_answer} ->
        #notify_parent({:saved, question_answer})

        {:noreply,
         socket
         |> put_flash(:info, "Question answer created successfully")
         |> redirect(to: "/quizzes/#{socket.assigns.quiz_id}/question/#{socket.assigns.question_id}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
