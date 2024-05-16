defmodule QuicWeb.QuestionLive.Forms do
  use QuicWeb, :author_live_view

  alias Quic.Quizzes
  alias Quic.Questions
  alias QuicWeb.QuicWebAux
  alias Quic.Questions.Question
  alias Quic.Questions.QuestionAnswer

  require Logger


  @impl true
  def mount(%{"question_id" => question_id, "quiz_id" => quiz_id} = _params, _session, socket) do
    if Quizzes.is_owner?(quiz_id, socket.assigns.current_author) do
      question = Questions.get_question!(question_id)
      question_changeset = Questions.change_question(question)

      {:ok, socket
          |> assign(:cant_submit_question, false)
          |> assign(:cant_submit_answers, false)
          |> assign(:quiz_id, quiz_id)
          |> assign(:question, question)
          |> assign(:type, question.type)
          |> assign(:answers, [])
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
      question_changeset = Questions.change_question(%Question{}, %{type: type}) |> Ecto.Changeset.put_assoc(:quiz, Quizzes.get_quiz!(quiz_id))
      answers_changesets = [
        Questions.change_question_answer(%QuestionAnswer{}),
        Questions.change_question_answer(%QuestionAnswer{}),
        Questions.change_question_answer(%QuestionAnswer{}),
        Questions.change_question_answer(%QuestionAnswer{})
      ]

      {:ok, socket
            |> assign(:cant_submit_question, true)
            |> assign(:cant_submit_answers, true)
            |> assign(:type, String.to_atom(type))
            |> assign(:quiz_id, quiz_id)
            |> assign(:answers, answers_changesets)
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
  def handle_event("validateQuestion", %{"question" => question_params}, socket) do
    question_params = Map.put(question_params, "type", socket.assigns.type)
    changeset =
      %Question{}
      |> Questions.change_question(question_params)
      |> Map.put(:action, :validate)

    socket = assign(socket, question_changeset: changeset)

    if Enum.count(changeset.errors) > 0 do
      {:noreply, assign(socket, cant_submit_question: true)}
    else
      {:noreply, assign(socket, cant_submit_question: false)}
    end
  end


  @impl true
  def handle_event("ignore", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("saveQuestion", _params, socket) do
    if Map.has_key?(socket.assigns, :question) do
      update_question(socket)
    else
      create_question(socket)
    end
  end

  @impl true
  def handle_event("clicked_view", %{"view" => view}, socket) do
    case view do
      "previewer" -> {:noreply, assign(socket, :view_selected, :previewer)}
      "editor" -> {:noreply, assign(socket, :view_selected, :editor)}
    end
  end




  defp update_question(socket) do
    question = socket.assigns.question
    answers_params = socket.assigns.answers
    changes_map = socket.assigns.question_changeset.changes
    question_params = %{
      "description" => (if Map.has_key?(changes_map, :description), do: changes_map.description, else: question.description),
      "points" => (if Map.has_key?(changes_map, :points), do: changes_map.points, else: question.points),
      "type" => (if Map.has_key?(changes_map, :type), do: changes_map.type, else: question.type),
    }

    case Questions.update_question(question, question_params, question.answers, answers_params) do
      {:ok, _question} ->
        Quizzes.update_quiz_points(socket.assigns.quiz_id)

        {:noreply, socket
                  |> put_flash(:info, "Question updated successfully!")}
                  #|> redirect(to: ~p"/quizzes/#{socket.assigns.quiz_id}/question/#{question.id}")}

      {:error, _changeset} ->
        {:noreply, socket |> put_flash(:error, "Something went wrong :(")}
    end
  end

  defp create_question(socket) do
    quiz_id = socket.assigns.quiz_id
    answers_params = socket.assigns.answers
    changes_map = socket.assigns.question_changeset.changes

    question_params = %{
      "description" => changes_map.description,
      "points" => changes_map.points,
      "type" => changes_map.type
    }

    case Questions.create_question(question_params, quiz_id, answers_params) do
      {:ok, question} ->
        Quizzes.update_quiz_points(quiz_id)

        {:noreply, socket
                  |> put_flash(:info, "Question created successfully!")
                  |> redirect(to: ~p"/quizzes/#{quiz_id}/question/#{question.id}")}

      {:error, _changeset} ->
        {:noreply, socket |> put_flash(:error, "Something went wrong :(")}
    end
  end

  # defp save_question(socket) do
  #   quiz_id = socket.assigns.quiz_id

  #   case Questions.create_question_with_quiz(question_params, quiz_id) do
  #     {:ok, question} ->
  #       #notify_parent({:saved, question})

  #       Quizzes.update_quiz_points(quiz_id)

  #       {:noreply,
  #        socket
  #        |> put_flash(:info, "Question created successfully")
  #        |> push_navigate(to: ~p"/quizzes/#{quiz_id}/question/#{question.id}")}

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       {:noreply, assign(socket, changeset: changeset)}
  #   end
  # end




  @impl true
  def handle_info({:cant_submit, params}, socket) do
    {:noreply, socket |> assign(:cant_submit_answers, params)}
  end

  @impl true
  def handle_info({:question_answers, answers}, socket) do
    {:noreply, socket |> assign(:answers, answers)}
  end

end
