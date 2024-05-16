defmodule QuicWeb.QuestionLive.Forms do
  use QuicWeb, :author_live_view

  alias Quic.Quizzes
  alias Quic.Questions
  alias Quic.Questions.Question
  alias Quic.Questions.QuestionAnswer
  alias QuicWeb.QuicWebAux


  @impl true
  def mount(%{"question_id" => question_id, "quiz_id" => quiz_id} = _params, _session, socket) do
    if Quizzes.is_owner?(quiz_id, socket.assigns.current_author) do
      question = Questions.get_question!(question_id)
      question_changeset = Questions.change_question(question)

      {:ok, socket
          |> assign(:quiz_id, quiz_id)
          |> assign(:question, question)
          |> assign(:type, question.type)
          |> assign(:answers, question.answers)
          |> assign(:question_changeset, question_changeset)
          |> assign(:view_selected, :editor)
          |> assign(:page_title, "Quiz - Edit Question")
          |> assign(:current_path, "/quizzes/#{quiz_id}/#{question_id}")}
    else
      {:ok, socket
            |> put_flash(:error, "You can only edit your own quizzes' questions!")
            |> push_navigate(to: ~p"/quizzes/#{quiz_id}/question/#{question_id}")}
    end
  end

  @impl true
  def mount(%{"type" => type, "quiz_id" => quiz_id} = _params, _session, socket) do

    if Quizzes.is_owner?(quiz_id, socket.assigns.current_author) do
      question_changeset = Questions.change_question(%Question{}) |> Ecto.Changeset.put_assoc(:quiz, Quizzes.get_quiz!(quiz_id))

      {:ok, socket
            |> assign(:type, String.to_atom(type))
            |> assign(:quiz_id, quiz_id)
            |> assign(:question_changeset, question_changeset)
            |> assign(:view_selected, :editor)
            |> assign(:page_title, "Quiz - New Question")
            |> assign(:current_path, "/quizzes/#{quiz_id}/new-question/#{type}")}
    else
      {:ok, socket
            |> put_flash(:error, "You can only edit your own quizzes' questions!")
            |> push_navigate(to: ~p"/quizzes/")}
    end
  end


  @impl true
  def handle_event("saveForm", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("validateQuestion", %{"question" => question_params}, socket) do
    changeset =
      %Question{}
      |> Questions.change_question(question_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, question_changeset: changeset)}
  end

  @impl true
  def handle_event("validateAnswer", %{"question_answer" => answer_params}, socket) do
    changeset =
      %QuestionAnswer{}
      |> Questions.change_question_answer(answer_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :answer_changeset, changeset)}
  end



  @impl true
  def handle_event("clicked_view", %{"view" => "previewer"}, socket) do
    {:noreply, assign(socket, :view_selected, :previewer)}
  end
  @impl true
  def handle_event("clicked_view", %{"view" => "editor"}, socket) do
    {:noreply, assign(socket, :view_selected, :editor)}
  end


  # defp readable_name(type) do
  #   case type do
  #     "single_choice" -> "Single Choice"
  #     "multiple_choice" -> "Multiple Choice"
  #     "true_false" -> "True or False"
  #     "open_answer" -> "Open Answer"
  #     "fill_the_blanks" -> "Fill in the Blanks"
  #     "fill_the_code" -> "Fill the Code"
  #     "code" -> "Code"
  #   end
  # end

  # defp get_type_color(type) do
  #   case type do
  #     "single_choice" -> "bg-[var(--turquoise)]"
  #     "multiple_choice" -> "bg-[var(--second-color)]"
  #     "true_false" -> "bg-[var(--blue)]"
  #     "open_answer" -> "bg-[var(--dark-green)]"
  #     "fill_the_blanks" -> "bg-[var(--fifth-color)]"
  #     "fill_the_code" -> "bg-[var(--third-color)]"
  #     "code" -> "bg-[var(--fourth-color)]"
  #   end
  # end

end
