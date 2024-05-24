defmodule QuicWeb.ParticipantLive.QuestionForm do

  use QuicWeb, :live_view

  alias Quic.Participants
  alias Quic.Questions


  @impl true
  def mount(%{"participant_id" => participant_id, "question_id" => question_id}, _session, socket) do
    participant = Participants.get_participant!(participant_id)
    code = participant.session.code
    question = Questions.get_question!(question_id)

    socket = push_event(socket, "join_session", %{code: code, username: participant.id})

    Phoenix.PubSub.subscribe(Quic.PubSub, "session:" <> code <> ":participant:" <> participant_id)
    Phoenix.PubSub.subscribe(Quic.PubSub, "session:" <> code)

    {:ok, socket
          |> assign(:session_code, code)
          |> assign(:participant, participant)
          |> assign(:selected_answer, (if question.type === :single_choice, do: nil, else: []))
          |> assign(:page_title, "Session #{code} - Question #{question.position}")
          |> assign(:question, question)
          |> assign(:has_submitted, false)}
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
      code: socket.assigns.session_code,
      response: socket.assigns.selected_answer,
      question_id: socket.assigns.question.id,
      participant_id: socket.assigns.participant.id
    })}
  end

  def handle_event(_, _, socket), do: {:noreply, socket}



  # SESSION CHANNEL MESSAGES
  @impl true
  def handle_info({"submission_results", %{"answer" => _results}}, socket) do
    {:noreply, socket |> assign(:has_submitted, true)}
  end

  @impl true
  def handle_info("submission_results_error", socket) do
    {:noreply, put_flash(socket, :error, "Something went wrong :(")}
  end

  @impl true
  def handle_info("monitor-closed-session", socket) do
    code = socket.assigns.session_code
    Phoenix.PubSub.unsubscribe(Quic.PubSub, "session:" <> code)
    Phoenix.PubSub.unsubscribe(Quic.PubSub, "session:" <> code <> ":participant:" <> socket.assigns.participant.id)

    {:noreply, socket
              |> put_flash(:info, "This Session has been closed by the Monitor. Hope you enjoyed it!")
              |> redirect(to: ~p"/")}
  end


  @impl true
  def handle_info({"next-question", %{"question" => question}}, socket) do
    Phoenix.PubSub.unsubscribe(Quic.PubSub, "session:" <> socket.assigns.session_code)
    Phoenix.PubSub.unsubscribe(Quic.PubSub, "session:" <> socket.assigns.session_code <> ":participant:" <> socket.assigns.participant.id)

    {:noreply, socket
              |> put_flash(:info, "Next Question!")
              |> redirect(to: ~p"/live-session/#{socket.assigns.participant.id}/question/#{question.id}")}
  end

  def handle_info(_, socket), do: {:noreply, socket}
end
