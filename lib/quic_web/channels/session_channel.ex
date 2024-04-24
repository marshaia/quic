defmodule QuicWeb.SessionChannel do
  require Logger
  use QuicWeb, :channel

  alias QuicWeb.SessionMonitor
  alias QuicWeb.SessionParticipant

  @impl true
  def join("session:" <> code = channel, payload, socket) do

    %{"username" => username, "isMonitor" => isMonitor} = payload
    socket = socket |> assign(session_code: code, channel: channel)

    # 1) verify session code validity
    if SessionMonitor.exists_session?(code) do
      session = SessionMonitor.get_session(code)

      # 2) verify user authorization
      if isMonitor do
        # if it's a Monitor, verify their authorization towards the session, i.e., if the Session belongs to them
        if SessionMonitor.session_belongs_to_monitor?(session.code, username) do
          # 3) add user to session channel and respond
          {:ok, socket}
        else
          # QuicWeb.Endpoint.broadcast(channel <> ":monitor", "disconnect", %{})
          {:error, %{reason: "You can't access Sessions that don't belong to you!"}}
        end

      # If it's a Participant, insert them in the DB in the associated Session
      else
        if SessionParticipant.participant_already_in_session?(username, session.code) do
          {:ok, socket}
        else
          # 3) add user to session channel and respond
          {:ok, participant} = SessionParticipant.create_participant(session, username)
          socket = assign(socket, :participant, participant)
          Phoenix.PubSub.broadcast(Quic.PubSub, socket.assigns.channel <> ":participant:" <> participant.name, {"joined_session", %{"participant" => participant}})
          Phoenix.PubSub.broadcast(Quic.PubSub, socket.assigns.channel <> ":monitor", {"participant_joined", %{"name" => participant.name}})
          {:ok, socket}
        end
      end


    # if the code isn't valid, i.e., the session isn't open
    else
      if isMonitor do
        {:ok, socket}
      else
        Phoenix.PubSub.broadcast(Quic.PubSub, socket.assigns.channel, {"error_joining_session", %{"error" => "Invalid Session Code"}})
        # QuicWeb.Endpoint.broadcast("session:#{code}:participant:#{username}", "disconnect", %{})
        {:error, %{reason: "Session doesn't exist"}}
      end
    end

    # #send(self(), :after_join)

    # if authorized?(payload) do
    #   {:ok, assign(socket, :session_id, id)}
    # else
    #   {:error, %{reason: "unauthorized"}}
    # end
  end


  @impl true
  def handle_in("participant_submitted_answer", %{"participant_id" => participant_id, "session_code" => code, "question_id" => question_id, "selected_answer" => answer_id}, socket) do

    # verify if participant is on the session
    if SessionParticipant.participant_already_in_session?(participant_id, code) do

      # update participant's current question
      SessionParticipant.update_participant_current_question(participant_id)

      # evaluate participant's submission
      results = SessionParticipant.access_submission(participant_id, question_id, answer_id)

      # update data base with Participant's results
      SessionParticipant.update_participant_results(participant_id, question_id, results)

      # send results to the Participant and Session Monitor
      name = SessionParticipant.get_participant_name(participant_id)
      Phoenix.PubSub.broadcast(Quic.PubSub, "session:" <> code <> ":monitor", {"participant_submitted_answer", %{"participant_name" => name, "answer" => results}})
      Phoenix.PubSub.broadcast(Quic.PubSub, "session:" <> code <> ":participant:" <> participant_id, {"submission_results", %{"answer" => results}})
    else
      {:noreply, socket}
    end
  end


  @impl true
  def handle_in("monitor-start-session", %{"session_code" => code, "email" => email}, socket) do
    if SessionMonitor.exists_session?(code) and SessionMonitor.session_belongs_to_monitor?(code, email) do
      first_question = SessionMonitor.start_session(code)
      Phoenix.PubSub.broadcast(Quic.PubSub, "session:" <> code, {"session-started", %{"question" => first_question}})
    end

    {:noreply, socket}
  end

  @impl true
  def handle_in("monitor-close-session", %{"session_code" => code, "email" => email}, socket) do
    if SessionMonitor.exists_session?(code) and SessionMonitor.session_belongs_to_monitor?(code, email) do
      case SessionMonitor.close_session(code) do
        {:ok, _} ->
          Phoenix.PubSub.broadcast(Quic.PubSub, "session:" <> code <> ":monitor", "monitor-session-closed")
          Phoenix.PubSub.broadcast(Quic.PubSub, "session:" <> code, "monitor-closed-session")

          {:error, _} ->
            Logger.error("RECEBNI EROOOOOOOOOOOOO")
            Phoenix.PubSub.broadcast(Quic.PubSub, "session:" <> code <> ":monitor", "monitor-unable-to-close-session")
      end

      {:noreply, socket}
    end

    {:noreply, socket}
  end

  # @impl true
  # def handle_info(:after_join, socket) do
  #   # broadcast(socket, "server_message", %{body: "joined"})
  #   {:noreply, socket}
  # end


  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  # @impl true
  # def handle_in("ping", payload, socket) do
  #   {:reply, {:ok, payload}, socket}
  # end

  # # It is also common to receive messages from the client and
  # # broadcast to everyone in the current topic (session:lobby).
  # @impl true
  # def handle_in("shout", payload, socket) do
  #   broadcast(socket, "shout", payload)
  #   {:noreply, socket}
  # end

  # Add authorization logic here as required.
  # defp authorized?(_payload) do
  #   true
  # end

  @impl true
  def handle_info(_, socket), do: {:noreply, socket}
end
