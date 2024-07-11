defmodule QuicWeb.SessionChannel do
  use QuicWeb, :channel

  alias Quic.{Sessions, Questions, Participants}

  @impl true
  def join("session:" <> code = channel, payload, socket) do
    %{"username" => username, "isMonitor" => isMonitor} = payload

    if isMonitor do
      %{"session_id" => session_id} = payload
      # verify Session id validity && Monitor ownership
      if Sessions.exists_session_with_id_and_code?(session_id, code) && Sessions.session_belongs_to_monitor?(session_id, username) do
        {:ok, socket}
      else
        {:error, %{reason: "You can't access Sessions that don't belong to you!"}}
      end

    # It's a Participant
    else
      # If Participant is already in Session
      if Participants.participant_already_in_session?(username, code) do
        {:ok, socket}
      else
        # If Session is still Open
        if Sessions.is_session_open?(code) do
         # add Participant to Session
          session = Sessions.get_open_session_by_code(code)
          {:ok, participant} = Participants.channel_create_participant(session, username)

          Phoenix.PubSub.broadcast(Quic.PubSub, channel <> ":monitor", "participant_joined")
          {:ok, %{"participant" => participant.id}, socket}

        # If Session is no longer Open
        else
          {:error, %{reason: "Invalid session code"}}
        end
      end
    end
  end



  # PARTICIPANT EVENTS
  @impl true
  def handle_in("participant_submitted_answer", %{"participant_id" => participant_id, "session_code" => code, "question_id" => question_id, "answer" => answer}, socket) do
    # verify if participant belongs to session
    if Participants.participant_already_in_session?(participant_id, code) do
      results = Questions.assess_submission(participant_id, question_id, answer)

      Participants.update_participant_results(participant_id, question_id, results)
      Participants.update_participant_current_question(participant_id)

      Phoenix.PubSub.broadcast(Quic.PubSub, "session:" <> code <> ":monitor", "participant_submitted_answer")
      Phoenix.PubSub.broadcast(Quic.PubSub, "session:" <> code <> ":participant:" <> participant_id, {"submission_results", %{"answer" => results}})

    else
      Phoenix.PubSub.broadcast(Quic.PubSub, "session:" <> code <> ":participant:" <> participant_id, "submission_results_error")
    end

    {:noreply, socket}
  end

  @impl true
  def handle_in("participant_next_question", %{"participant_id" => participant_id, "code" => code, "current_question" => current_question}, socket) do
    # verify if participant belongs to session
    if Participants.participant_already_in_session?(participant_id, code) do
      case Participants.get_participant_next_question(participant_id, current_question) do
        {:ok, question} -> Phoenix.PubSub.broadcast(Quic.PubSub, "session:" <> code <> ":participant:" <> participant_id, {"next_question", %{"question" => question}})
        {:error_max_questions, _} -> Phoenix.PubSub.broadcast(Quic.PubSub, "session:" <> code <> ":participant:" <> participant_id, {"next_question_error", %{"msg" => "You already answered all questions!"}})
        {:error_invalid_question, _} -> Phoenix.PubSub.broadcast(Quic.PubSub, "session:" <> code <> ":participant:" <> participant_id, {"next_question_error", %{"msg" => "Invalid question request!"}})
      end
    else
      Phoenix.PubSub.broadcast(Quic.PubSub, "session:" <> code <> ":participant:" <> participant_id, "submission_results_error")
    end

    {:noreply, socket}
  end



  # MONITOR EVENTS
  @impl true
  def handle_in("monitor-start-session", %{"session_code" => code, "session_id" => session_id, "email" => email}, socket) do
    # verify if Session exists and Monitor ownership
    if Sessions.exists_session_with_id?(session_id) and Sessions.session_belongs_to_monitor?(session_id, email) do
      case Sessions.start_session(session_id) do
        {:ok, first_question} -> Phoenix.PubSub.broadcast(Quic.PubSub, "session:" <> code, {"session-started", %{"question" => first_question}})
        {:error, _} -> Phoenix.PubSub.broadcast(Quic.PubSub, "session:" <> code <> ":monitor", "error-starting-session")
      end
    end
    {:noreply, socket}
  end

  @impl true
  def handle_in("monitor-close-session", %{"session_code" => code, "session_id" => session_id, "email" => email}, socket) do
    # verify if Session exists and Monitor ownership
    if Sessions.exists_session_with_id?(session_id) and Sessions.session_belongs_to_monitor?(session_id, email) do
      case Sessions.close_session(session_id) do
        {:ok, _} -> Phoenix.PubSub.broadcast(Quic.PubSub, "session:" <> code, "monitor-closed-session")
        {:error, _} -> Phoenix.PubSub.broadcast(Quic.PubSub, "session:" <> code <> ":monitor", "error-closing-session")
      end
    end
    {:noreply, socket}
  end

  @impl true
  def handle_in("monitor-next-question", %{"session_code" => code, "session_id" => session_id, "email" => email}, socket) do
    # verify if Session exists and Monitor ownership
    if Sessions.exists_session_with_id?(session_id) and Sessions.session_belongs_to_monitor?(session_id, email) do
      case Sessions.next_question(session_id) do
        {:ok, next_question} -> Phoenix.PubSub.broadcast(Quic.PubSub, "session:" <> code, {"next_question", %{"question" => next_question}})
        {:error, _} -> Phoenix.PubSub.broadcast(Quic.PubSub, "session:" <> code <> ":monitor", "error-next-question")
      end
    end
    {:noreply, socket}
  end


  @impl true
  def handle_info(_, socket), do: {:noreply, socket}
end
