defmodule QuicWeb.QuestionLive.Form do
  use QuicWeb, :author_live_view

  alias Quic.Quizzes
  alias Quic.Questions
  alias Quic.Parameters
  alias Quic.Questions.Question
  alias Quic.Parameters.Parameter
  alias Quic.Questions.QuestionAnswer

  @impl true
  def mount(%{"question_id" => question_id, "quiz_id" => quiz_id} = _params, _session, socket) do
    if Quizzes.is_owner?(quiz_id, socket.assigns.current_author) do
      question = Questions.get_question!(question_id)
      question_changeset = Questions.change_question(question)

      {:ok, socket
          |> assign(:cant_submit_question, false)
          |> assign(:cant_submit_answers, false)
          |> assign(:error_answers, nil)
          |> assign(:quiz_id, quiz_id)
          |> assign(:question, question)
          |> assign(:type, question.type)
          |> assign(:answers, create_answers_changesets(question.type, %{new_question: false, question: question}))
          |> assign(:parameters_changeset, Parameters.create_parameters_changeset(question.type, %{new_question: false, question: question}))
          |> assign(:question_changeset, question_changeset)
          |> assign(:view_selected, :editor)
          |> assign(:page_title, "Quiz - Edit Question")
          |> assign(:loading, true)}
    else
      {:ok, socket
            |> put_flash(:error, "You can only edit your own quizzes' questions!")
            |> push_navigate(to: ~p"/quizzes/#{quiz_id}/question/#{question_id}")}
    end
  end

  @impl true
  def mount(%{"type" => type, "quiz_id" => quiz_id} = _params, _session, socket) do
    if Quizzes.is_owner?(quiz_id, socket.assigns.current_author) do
      type = String.to_atom(type)
      question_changeset = Map.put(%{}, :type, type) |> Map.put(:points, 0)
      question_changeset = Questions.create_question_placeholders(type, question_changeset)
      question_changeset = Questions.change_question(%Question{}, question_changeset) |> Ecto.Changeset.put_assoc(:quiz, Quizzes.get_quiz!(quiz_id))

      {:ok, socket
            |> assign(:cant_submit_question, true)
            |> assign(:cant_submit_answers, (if type === :true_false || type === :open_answer, do: false, else: true))
            |> assign(:error_answers, nil)
            |> assign(:type, type)
            |> assign(:quiz_id, quiz_id)
            |> assign(:quiz_num_questions, Quizzes.get_quiz_num_questions!(quiz_id))
            |> assign(:answers, create_answers_changesets(type, %{new_question: true}))
            |> assign(:parameters_changeset, Parameters.create_parameters_changeset(type, %{new_question: true}))
            |> assign(:question_changeset, question_changeset)
            |> assign(:view_selected, :editor)
            |> assign(:page_title, "Quiz - New Question")
            |> assign(:loading, true)}
    else
      {:ok, socket
            |> put_flash(:error, "You can only edit your own quizzes' questions!")
            |> push_navigate(to: ~p"/quizzes/")}
    end
  end

  @impl true
  def handle_params(%{"question_id" => question_id, "quiz_id" => quiz_id}, _uri, socket) do
    {:noreply, socket |> assign(:current_path, "/quizzes/#{quiz_id}/edit-question/#{question_id}")}
  end

  @impl true
  def handle_params(%{"type" => type, "quiz_id" => quiz_id}, _uri, socket) do
    {:noreply, socket |> assign(:current_path, "/quizzes/#{quiz_id}/new-question/#{type}")}
  end


  @impl true
  def handle_event("validateQuestion", %{"question" => params}, socket) do
    changeset = socket.assigns.question_changeset
    code = if Map.has_key?(changeset.changes, :code), do: changeset.changes.code, else: (if Map.has_key?(changeset.data, :code), do: changeset.data.code, else: "")
    question_params = params |> Map.put("code", code)

    validateQuestion(question_params, socket)
  end

  @impl true
  def handle_event("ignore", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("saveQuestion", _params, socket) do
    if Map.has_key?(socket.assigns, :question), do: update_question(socket), else: create_question(socket)
  end

  @impl true
  def handle_event("clicked_view", %{"view" => view}, socket) do
    case view do
      "previewer" -> {:noreply, assign(socket, :view_selected, :previewer)}
      "editor" -> {:noreply, assign(socket, :view_selected, :editor)}
    end
  end

  @impl true
  def handle_event("clear", _params, socket) do
    question = %Question{} |> Questions.change_question(%{"points" => 0, "description" => ""})
    parameters = %Parameter{} |> Parameters.change_parameter(%{"language" => :c, "code" => "", "test_file" => "", "correct_answers" => %{}, "tests" => []})

    socket = push_event(socket, "clear_editor", %{})
    {:noreply, socket |> assign(parameters_changeset: parameters, question_changeset: question, loading: false)}
  end

  # Hook Events
  @impl true
  def handle_event("update_parameter", params, socket) do
    parsed_params = Parameters.evaluate_params(params)
    params = Parameters.get_parameters_map(params, socket.assigns.parameters_changeset) |> Map.merge(parsed_params)
    changeset = %Parameter{} |> Parameters.change_parameter(params) |> Map.put(:action, :validate)
    socket = socket |> assign(:loading, false) |> assign(:parameters_changeset, changeset)

    if Enum.count(changeset.errors) > 0, do: {:noreply, assign(socket, cant_submit_answers: true)}, else: {:noreply, assign(socket, cant_submit_answers: false)}
  end




  def validateQuestion(question_params, socket) do
    position = (if Map.has_key?(socket.assigns, :question), do: socket.assigns.question.position, else: socket.assigns.quiz_num_questions)
    question_params = question_params |> Map.put("type", socket.assigns.type) |> Map.put("position", position)
    changeset = %Question{} |> Questions.change_question(question_params) |> Map.put(:action, :validate)
    socket = assign(socket, question_changeset: changeset) |> assign(:loading, false)

    if Enum.count(changeset.errors) > 0, do: {:noreply, assign(socket, cant_submit_question: true)}, else: {:noreply, assign(socket, cant_submit_question: false)}
  end


  defp update_question(socket) do
    question = socket.assigns.question
    answers_params = socket.assigns.answers
    changes_map = socket.assigns.question_changeset.changes
    question_params = %{
      "description" => (if Map.has_key?(changes_map, :description), do: changes_map.description, else: question.description),
      "points" => (if Map.has_key?(changes_map, :points), do: changes_map.points, else: question.points),
      "type" => question.type,
    }

    case Questions.update_question(question, question_params, answers_params, socket.assigns.parameters_changeset) do
      {:ok, question} ->
        Quizzes.update_quiz_points(socket.assigns.quiz_id)

        {:noreply, socket
                  |> put_flash(:info, "Question updated successfully!")
                  |> redirect(to: ~p"/quizzes/#{socket.assigns.quiz_id}/question/#{question.id}")}

      {:error, _changeset} -> {:noreply, socket |> put_flash(:error, "Something went wrong :(")}
    end
  end

  defp create_question(socket) do
    quiz_id = socket.assigns.quiz_id
    answers_params = socket.assigns.answers
    parameters = socket.assigns.parameters_changeset
    changes_map = socket.assigns.question_changeset.changes

    question_params = %{
      "description" => changes_map.description,
      "points" => changes_map.points,
      "type" => changes_map.type,
      "position" => socket.assigns.quiz_num_questions + 1,
    }

    case Questions.create_question(question_params, quiz_id, answers_params, parameters) do
      {:ok, question} ->
        Quizzes.update_quiz_points(quiz_id)

        {:noreply, socket
                  |> put_flash(:info, "Question created successfully!")
                  |> redirect(to: ~p"/quizzes/#{quiz_id}/question/#{question.id}")}

      {:error, _changeset} -> {:noreply, socket |> put_flash(:error, "Something went wrong :(")}
    end
  end

  defp create_answers_changesets(type, %{new_question: new_question} = params) do
    if new_question do
      case type do
        t when t in [:single_choice, :multiple_choice] ->
          [
            Questions.change_question_answer(%QuestionAnswer{}),
            Questions.change_question_answer(%QuestionAnswer{}),
            Questions.change_question_answer(%QuestionAnswer{}),
            Questions.change_question_answer(%QuestionAnswer{}),
          ]
        :true_false -> [Questions.change_question_answer(%QuestionAnswer{}, %{"is_correct" => false, "answer" => "."})]
        :fill_the_blanks -> [Questions.change_question_answer(%QuestionAnswer{}, %{"is_correct" => true, "answer" => "correct"})]
        _ -> []
      end

    else
      %{question: question} = params
      Enum.reduce(question.answers, [], fn answer, acc -> [Questions.change_question_answer(answer) | acc] end) |> Enum.reverse
    end
  end



  @impl true
  def handle_info({:changed_language, params}, socket) do
    params = Parameters.get_parameters_map(params, socket.assigns.parameters_changeset) |> Map.merge(params)
    changeset = %Parameter{} |> Parameters.change_parameter(params) |> Map.put(:action, :validate)
    socket = socket |> assign(:loading, false) |> assign(:parameters_changeset, changeset)

    if Enum.count(changeset.errors) > 0, do: {:noreply, assign(socket, cant_submit_answers: true)}, else: {:noreply, assign(socket, cant_submit_answers: false)}
  end

  @impl true
  def handle_info({:cant_submit, params}, socket) do
    {:noreply, socket |> assign(:cant_submit_answers, params)}
  end

  @impl true
  def handle_info({:question_answers, answers}, socket) do
    {:noreply, socket |> assign(:answers, answers)}
  end

  @impl true
  def handle_info(:no_error_answers, socket) do
    {:noreply, socket |> assign(:error_answers, nil)}
  end

  @impl true
  def handle_info({:error_answers, msg}, socket) do
    {:noreply, socket |> assign(:error_answers, msg)}
  end

end
