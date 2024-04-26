defmodule QuicWeb.ParticipantLive.QuestionForm do

  use QuicWeb, :live_view

  alias Quic.Participants
  alias Quic.Questions


  @impl true
  def mount(%{"participant_id" => participant_id, "question_id" => question_id}, _session, socket) do
    participant = Participants.get_participant!(participant_id)
    code = participant.session.code

    socket = push_event(socket, "join_session", %{code: code, username: participant.id})

    # Phoenix.PubSub.subscribe(Quic.PubSub, "session:" <> code <> ":participant:" <> participant_id)
    Phoenix.PubSub.subscribe(Quic.PubSub, "session:" <> code)

    {:ok, socket
          |> assign(:session_code, code)
          |> assign(:participant, participant)
          |> assign(:selected_answer, nil)
          |> assign(:page_title, "Session #{code} - Question ?")
          |> assign(:question, Questions.get_question!(question_id))}

    # case Sessions.get_session!(participant.session.id) do
    #   nil -> {:ok, redirect(socket, to: ~p"/")}
    #   session ->
    #     if session.status !== :open do
    #       {:ok, redirect(socket, to: ~p"/")}
    #     else
    #       {:ok, socket
    #       |> assign(:session_code, code)
    #       |> assign(participant: participant)
    #       |> assign(:selected_answer, nil)
    #       |> assign(:page_title, "Session #{code} - Question ?")
    #       |> assign(:question, Questions.get_question!(question_id))}
    #     end
    # end
  end


  # SELECTED ANSWER
  @impl true
  def handle_event("selected-answer", %{"id" => answer_id}, socket) do
    #socket = push_event(socket, "store", %{key: "answer", data: answer_id})
    {:noreply, socket |> assign(:selected_answer, answer_id)}
  end

  @impl true
  def handle_event("submit-answer-btn", _params, socket) do
    {:noreply, socket |> push_event("participant-submit-answer", %{code: socket.assigns.session_code, answer_id: socket.assigns.selected_answer, question_id: socket.assigns.question.id, participant_id: socket.assigns.participant.id})}
  end

  @impl true
  def handle_event("submission_results", %{"answer" => results}, socket) do
    if results do
      {:noreply, put_flash(socket, :info, "Correct Answer!")}
    else
      {:noreply, put_flash(socket, :error, "Wrong Answer! :(")}
    end
  end

  @impl true
  def handle_event("submission_results_error", _payload, socket) do
    {:noreply, put_flash(socket, :error, "Something went wrong :(")}
  end

  @impl true
  def handle_event("participant_submitted_answer", %{"answer" => results}, socket) do
    if results do
      {:noreply, put_flash(socket, :info, "Correct Answer!")}
    else
      {:noreply, put_flash(socket, :error, "Wrong Answer :(")}
    end
  end

  @impl true
  def handle_event(_, _unsigned_params, socket), do: {:noreply, socket}


  # SESSION CHANNEL MESSAGES
  # @impl true
  # def handle_info({"submission_results", %{"answer" => results}}, socket) do
  #   if results do
  #     {:noreply, put_flash(socket, :info, "Correct Answer!")}
  #   else
  #     {:noreply, put_flash(socket, :error, "Wrong Answer :(")}
  #   end
  # end

  @impl true
  def handle_info("monitor-closed-session", socket) do
    {:noreply, socket
              |> put_flash(:info, "This Session has been closed by the Monitor. Hope you enjoyed it!")
              |> redirect(to: ~p"/")}
  end

  def handle_info(_, socket), do: {:noreply, socket}
end
