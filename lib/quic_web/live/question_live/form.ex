defmodule QuicWeb.QuestionLive.Form do
  use QuicWeb, :author_live_view

  alias Quic.Quizzes
  alias Quic.Questions
  alias Quic.Questions.Question
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
      question_changeset = Questions.change_question(%Question{}, %{type: type, points: 0, code: "int sum ([[res1]], int b) {\n  return [[res2]];\n}"}) |> Ecto.Changeset.put_assoc(:quiz, Quizzes.get_quiz!(quiz_id))

      {:ok, socket
            |> assign(:cant_submit_question, true)
            |> assign(:cant_submit_answers, (if type === "true_false" || type === "open_answer", do: false, else: true))
            |> assign(:error_answers, nil)
            |> assign(:type, String.to_atom(type))
            |> assign(:quiz_id, quiz_id)
            |> assign(:quiz_num_questions, Quizzes.get_quiz_num_questions!(quiz_id))
            |> assign(:answers, create_answers_changesets(String.to_atom(type), %{new_question: true}))
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
    position = (if Map.has_key?(socket.assigns, :question), do: socket.assigns.question.position, else: socket.assigns.quiz_num_questions)
    question_params = params
      |> Map.put("type", socket.assigns.type)
      |> Map.put("position", position)

    changeset =
      %Question{}
      |> Questions.change_question(question_params)
      |> Map.put(:action, :validate)

    socket = assign(socket, question_changeset: changeset) |> assign(:loading, false)

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
  def handle_event("update_code_answer", params, socket) do
    answer_params = Map.put(params, "is_correct", true)
    changeset =
      %QuestionAnswer{}
      |> Questions.change_question_answer(answer_params)
      |> Map.put(:action, :validate)

    socket = socket |> assign(:answers, [changeset]) |> assign(:loading, false)

    if answer_valid?(changeset) do
      {:noreply, socket |> assign(:cant_submit_answers, false)}
    else
      {:noreply, socket |> assign(:cant_submit_answers, true)}
    end
  end



  defp answer_valid?(changeset) do
    if Enum.count(changeset.errors) > 0, do: false, else: true
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
      {:ok, question} ->
        Quizzes.update_quiz_points(socket.assigns.quiz_id)

        {:noreply, socket
                  |> put_flash(:info, "Question updated successfully!")
                  |> redirect(to: ~p"/quizzes/#{socket.assigns.quiz_id}/question/#{question.id}")}

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
      "type" => changes_map.type,
      "position" => socket.assigns.quiz_num_questions + 1
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
        :open_answer -> []
        :fill_the_blanks -> [Questions.change_question_answer(%QuestionAnswer{}, %{"is_correct" => true})]
        :fill_the_code -> [Questions.change_question_answer(%QuestionAnswer{}, %{"is_correct" => true, "answer" => "[[res1]]:int a\n[[res2]]:a+b"})]
        :code -> [Questions.change_question_answer(%QuestionAnswer{}, %{"is_correct" => true, "answer" => "int sum (int a, int b) {\n  return a+b;\n}"})]
      end

    else
      %{question: question} = params
      Enum.reduce(question.answers, [], fn answer, acc -> [Questions.change_question_answer(answer) | acc] end) |> Enum.reverse
    end
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
