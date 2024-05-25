defmodule QuicWeb.ParticipantLive.QuestionForm do

  use QuicWeb, :live_view

  alias Quic.Participants
  alias Quic.Questions
  alias Quic.Sessions
  alias QuicWeb.QuicWebAux


  @impl true
  def mount(%{"participant_id" => participant_id, "question_id" => question_id}, _session, socket) do
    participant = Participants.get_participant!(participant_id)
    question = Questions.get_question!(question_id)
    session = Sessions.get_session!(participant.session.id)

    if participant.session.status === :closed do
      {:ok, socket |> put_flash(:error, "Session is closed!") |> redirect(to: ~p"/")}

    else
      if session.current_question !== question.position do
        new_question_id = Enum.at(session.quiz.questions, session.current_question - 1, nil)
        {:ok, socket |> put_flash(:error, "Wrong question! Sending you to the right one :)") |> redirect(to: ~p"/live-session/#{participant.id}/question/#{new_question_id}")}

      else
        code = participant.session.code
        has_submitted = Enum.any?(participant.answers, fn a -> a.question.id === question_id end)
        last_question = session.current_question === Enum.count(session.quiz.questions)

        socket = push_event(socket, "join_session", %{code: code, username: participant.id})
        Phoenix.PubSub.subscribe(Quic.PubSub, "session:" <> code <> ":participant:" <> participant_id)
        Phoenix.PubSub.subscribe(Quic.PubSub, "session:" <> code)

        {:ok, socket
              |> assign(:session, session)
              |> assign(:participant, participant)
              |> assign(:selected_answer, (if question.type === :single_choice, do: nil, else: []))
              |> assign(:page_title, "Session #{code} - Question #{question.position}")
              |> assign(:question, question)
              |> assign(:has_submitted, has_submitted)
              |> assign(:last_question, last_question)}
      end
    end
  end


  # SELECTED ANSWER
  @impl true
  def handle_event("selected-answer", %{"answer" => answer}, socket) do
    if socket.assigns.question.type === :multiple_choice do
      previous_selected_answers = socket.assigns.selected_answer
      if Enum.member?(previous_selected_answers, answer) do
        {:noreply, socket |> assign(:selected_answer, Enum.reject(previous_selected_answers, fn id -> id === answer end))}
      else
        {:noreply, socket |> assign(:selected_answer, Enum.concat(previous_selected_answers, [answer]))}
      end

    else
      {:noreply, socket |> assign(:selected_answer, answer)}
    end
  end

  @impl true
  def handle_event("submit-answer-btn", _params, socket) do
    {:noreply, socket |> push_event("participant-submit-answer", %{
      code: socket.assigns.session.code,
      response: socket.assigns.selected_answer,
      question_id: socket.assigns.question.id,
      participant_id: socket.assigns.participant.id
    })}
  end

  def handle_event(_, _, socket), do: {:noreply, socket}



  # SESSION CHANNEL MESSAGES
  @impl true
  def handle_info({"submission_results", %{"answer" => _results}}, socket) do
    {:noreply, socket |> assign(:has_submitted, true) |> assign(:participant, Participants.get_participant!(socket.assigns.participant.id))}
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
  def handle_info({"next-question", %{"question" => question}}, socket) do
    Phoenix.PubSub.unsubscribe(Quic.PubSub, "session:" <> socket.assigns.session.code)
    Phoenix.PubSub.unsubscribe(Quic.PubSub, "session:" <> socket.assigns.session.code <> ":participant:" <> socket.assigns.participant.id)

    {:noreply, socket
              |> put_flash(:info, "Next Question!")
              |> redirect(to: ~p"/live-session/#{socket.assigns.participant.id}/question/#{question.id}")}
  end

  def handle_info(_, socket), do: {:noreply, socket}
end
