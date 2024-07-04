defmodule QuicWeb.ParticipantLive.QuestionForm do
  use QuicWeb, :live_view

  alias QuicWeb.QuicWebAux
  alias Quic.{Sessions, Participants}

  @impl true
  def mount(%{"participant_id" => participant_id, "question_position" => question_position}, _session, socket) do
    {question_position, _} = Integer.parse(question_position)

    case Participants.get_participant(participant_id) do
      nil -> {:ok, socket |> put_flash(:error, "Invalid Participant") |> redirect(to: ~p"/")}
      participant ->
        session = Sessions.get_session!(participant.session.id)
        question = Enum.find(session.quiz.questions, fn q -> q.position === question_position end)

        if participant.session.status === :closed do
          {:ok, socket |> put_flash(:error, "Session is closed!") |> redirect(to: ~p"/")}

        else
          question_position = if question === nil, do: -1, else: question.position

          if session.type === :monitor_paced && session.current_question !== question_position do
            new_question = Enum.find(session.quiz.questions, nil, fn q -> q.position === session.current_question end)
            {:ok, socket |> put_flash(:error, "Wrong question! Sending you to the right one :)") |> redirect(to: ~p"/live-session/#{participant.id}/question/#{new_question.position}")}

          else
            has_answered_last_question = participant.current_question === Enum.count(session.quiz.questions)
            expected_position = if has_answered_last_question, do: participant.current_question, else: participant.current_question + 1

            if session.type === :participant_paced && expected_position !== question_position do
              {:ok, socket |> put_flash(:error, "Wrong question! Sending you to the right one :)") |> redirect(to: ~p"/live-session/#{participant.id}/question/#{expected_position}")}

            else
              code = participant.session.code
              has_submitted = Enum.any?(participant.answers, fn a -> a.question_id === question.id end)
              answers = Enum.filter(session.quiz.answers, fn a -> a.question_id === question.id end)
              last_question = (if session.type === :monitor_paced, do: session.current_question === Enum.count(session.quiz.questions), else: (participant.current_question + 1) >= Enum.count(session.quiz.questions))

              parameters =  Enum.find(session.quiz.parameters, fn p -> p.question_id === question.id end)
              socket = if question.type === :fill_the_code || question.type === :code, do: push_event(socket, "change_language", %{"language" => parameters.language}), else: socket

              socket = push_event(socket, "join_session", %{code: code, username: participant.id})
              Phoenix.PubSub.subscribe(Quic.PubSub, "session:" <> code <> ":participant:" <> participant_id)
              Phoenix.PubSub.subscribe(Quic.PubSub, "session:" <> code)

              parameters = (if question.type === :code || question.type === :fill_the_code, do: Enum.find(session.quiz.parameters, fn p -> p.question_id === question.id end), else: nil)
              answer_changeset = (if parameters !== nil do
                if question.type === :fill_the_code, do: Enum.reduce(parameters.correct_answers, %{}, fn {key, _value}, acc -> Map.put(acc, key, "") end), else: parameters.code
              else "" end)

              {:ok, socket
                    |> assign(:session, session)
                    |> assign(:participant, participant)
                    |> assign(:selected_answer, (if question.type === :single_choice, do: nil, else: []))
                    |> assign(:page_title, "Session #{code} - Question #{question.position}")
                    |> assign(:question, question)
                    |> assign(:answers, answers)
                    |> assign(:has_submitted, has_submitted)
                    |> assign(:last_question, last_question)
                    |> assign(:answer_changeset, %{"answer" => answer_changeset})
                    |> assign(:parameters, parameters)
                    |> assign(:loading, true)}
            end
          end
        end
    end
  end


  @impl true
  def handle_event("selected-answer", %{"answer" => answer} = params, socket) do
    if socket.assigns.question.type === :multiple_choice do
      previous_selected_answers = socket.assigns.selected_answer
      if Enum.member?(previous_selected_answers, answer) do
        {:noreply, socket |> assign(:selected_answer, Enum.reject(previous_selected_answers, fn id -> id === answer end))}
      else
        {:noreply, socket |> assign(:selected_answer, Enum.concat(previous_selected_answers, [answer]))}
      end

    else
      if Map.has_key?(params, "value"), do: {:noreply, socket |> assign(:selected_answer, answer)}, else: {:noreply, socket |> assign(:selected_answer, nil)}
    end
  end

  @impl true
  def handle_event("submit-answer-btn", _params, socket) do
    question_type = socket.assigns.question.type
    response = (if question_type === :true_false || question_type === :single_choice || question_type === :multiple_choice, do: socket.assigns.selected_answer, else: (if question_type === :fill_the_code, do: Map.get(socket.assigns.answer_changeset, "answer", %{}), else: Map.get(socket.assigns.answer_changeset, "answer", "")))

    event_params = %{
      code: socket.assigns.session.code,
      response: response,
      question_id: socket.assigns.question.id,
      participant_id: socket.assigns.participant.id
    }

    {:noreply, socket |> push_event("participant-submit-answer", event_params) |> assign(:has_submitted, true)}
  end

  @impl true
  def handle_event("validate_participant_answer", %{"answer_id" => answer_id, "answer" => answer}, socket) do
    {:noreply, socket |> assign(:answer_changeset, %{"answer" => Map.put(socket.assigns.answer_changeset["answer"], answer_id, answer)}) |> assign(:loading, false)}
  end

  @impl true
  def handle_event("validate_participant_answer", %{"answer" => answer}, socket) do
    {:noreply, socket |> assign(:answer_changeset, %{"answer" => answer}) |> assign(:loading, false)}
  end

  @impl true
  def handle_event("next_question", _params, socket) do
    if socket.assigns.session.type === :participant_paced && (socket.assigns.last_question === false) do
      {:noreply, socket |> push_event("participant-next-question", %{participant_id: socket.assigns.participant.id, current_question: socket.assigns.question.position, code: socket.assigns.session.code})}
    else
      {:noreply, socket}
    end
  end

  def handle_event(_, _, socket), do: {:noreply, socket}


  # SESSION CHANNEL MESSAGES
  @impl true
  def handle_info({"submission_results", %{"answer" => _results}}, socket) do
    socket = socket |> assign(:participant, Participants.get_participant!(socket.assigns.participant.id)) |> assign(:results, true)
    if socket.assigns.session.type === :participant_paced && (socket.assigns.last_question === false) && not socket.assigns.session.immediate_feedback do
      {:noreply, socket |> push_event("participant-next-question", %{participant_id: socket.assigns.participant.id, current_question: socket.assigns.question.position, code: socket.assigns.session.code})}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info("submission_results_error", socket) do
    {:noreply, put_flash(socket, :error, "Something went wrong :(")}
  end

  @impl true
  def handle_info("monitor-closed-session", socket) do
    code = socket.assigns.session.code
    Phoenix.PubSub.unsubscribe(Quic.PubSub, "session:" <> code)
    Phoenix.PubSub.unsubscribe(Quic.PubSub, "session:" <> code <> ":participant:" <> socket.assigns.participant.id)

    {:noreply, socket
              |> put_flash(:info, "This Session has been closed by the Monitor. Hope you enjoyed it!")
              |> redirect(to: ~p"/")}
  end

  @impl true
  def handle_info({"next_question", %{"question" => question}}, socket) do
    Phoenix.PubSub.unsubscribe(Quic.PubSub, "session:" <> socket.assigns.session.code)
    Phoenix.PubSub.unsubscribe(Quic.PubSub, "session:" <> socket.assigns.session.code <> ":participant:" <> socket.assigns.participant.id)

    {:noreply, socket |> redirect(to: ~p"/live-session/#{socket.assigns.participant.id}/question/#{question.position}")}
  end

  @impl true
  def handle_info({"next_question_error", %{"msg" => msg}}, socket) do
    {:noreply, put_flash(socket, :error, msg)}
  end

  def handle_info(_, socket), do: {:noreply, socket}


  defp cant_submit?(question_type, selected_answer, changeset) do
    if question_type === :true_false || question_type === :single_choice || question_type === :multiple_choice do
      selected_answer === nil || selected_answer === []
    else
      if question_type === :fill_the_code do
        %{"answer" => answers} = changeset
        Enum.reduce(answers, false, fn {_key, value}, acc -> acc || String.length(value) === 0 end)
      else
        String.length(Map.get(changeset, "answer", "")) === 0
      end
    end
  end
end
