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

  @impl true
  def handle_event("duplicate", %{"id" => id}, socket) do
    answer = Questions.get_question_answer!(id)
    answer_params = %{
      "answer" => answer.answer,
      "is_correct" => answer.is_correct,
    }

    question_id = socket.assigns.question.id

    case Questions.create_answer_with_question(answer_params, question_id) do
      {:ok, _answer} ->

        {:noreply, socket
                  |> assign(:question, Questions.get_question!(question_id))
                  |> put_flash(:info, "Answer duplicated successfully!")}

      {:error, _changeset} ->
        {:noreply, socket |> put_flash(:error, "Something went wrong :(")}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    answer = Questions.get_question_answer!(id)

    case Questions.delete_question_answer(answer) do
      {:ok, _} ->
        {:noreply, socket
                  |> assign(:question, Questions.get_question!(socket.assigns.question.id))
                  |> put_flash(:info, "Answer eliminated successfully!")}

      {:error, _changeset} ->
        {:noreply, socket |> put_flash(:error, "Something went wrong :(")}
    end
  end

  defp readable_name(type) do
    case type do
      :multiple_choice -> "Multiple Choice"
      :true_false -> "True or False"
      :open_answer -> "Open Answer"
      :fill_the_blanks -> "Fill in the Blanks"
      :fill_the_code -> "Fill the Code"
      :code -> "Code"
    end
  end

  defp get_type_color(type) do
    case type do
      :multiple_choice -> "bg-[var(--second-color)]"
      :true_false -> "bg-[var(--blue)]"
      :open_answer -> "bg-[var(--dark-green)]"
      :fill_the_blanks -> "bg-[var(--fifth-color)]"
      :fill_the_code -> "bg-[var(--third-color)]"
      :code -> "bg-[var(--fourth-color)]"
    end
  end

  defp page_title(:show), do: "Show Question"
  defp page_title(:edit), do: "Edit Question"
end
