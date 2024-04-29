defmodule QuicWeb.SessionChannel do
  require Logger
  use QuicWeb, :channel

  alias Quic.Sessions
  alias QuicWeb.SessionMonitor
  alias QuicWeb.SessionParticipant

  @impl true
  def join("session:" <> code = channel, payload, socket) do

    %{"username" => username, "isMonitor" => isMonitor} = payload
    #socket = socket |> assign(session_code: code, channel: channel)

    if isMonitor do
      %{"session_id" => session_id} = payload

      # verify Session id validity && Monitor ownership
      if SessionMonitor.exists_session_with_id_and_code?(session_id, code) && SessionMonitor.session_belongs_to_monitor?(session_id, username) do
        {:ok, socket}
      else
        {:error, %{reason: "You can't access Sessions that don't belong to you!"}}
      end

    # It's a Participant
    else
      # If Participant is already in Session
      if SessionParticipant.participant_already_in_session?(username, code) do
        {:ok, socket}
      else
        # If Session is still Open
        if SessionParticipant.session_is_open?(code) do
         # add Participant to Session and respond
          session = Sessions.get_open_session_by_code(code)
          {:ok, participant} = SessionParticipant.create_participant(session, username)
          #socket = assign(socket, :participant, participant)

          #Phoenix.PubSub.broadcast(Quic.PubSub, channel <> ":participant:" <> participant.name, {"joined_session", %{"participant" => participant}})
          Phoenix.PubSub.broadcast(Quic.PubSub, channel <> ":monitor", {"participant_joined", %{"name" => participant.name}})

          {:ok, %{"participant" => participant.id}, socket}

        # If Session is no longer Open
        else
          # Phoenix.PubSub.broadcast(Quic.PubSub, channel <> ":participant:" <> username, {"error_joining_session", %{"error" => "Invalid Session Code"}})
          {:error, %{reason: "Invalid session code"}}
        end
      end
    end
  end




  # def join("session:" <> code = channel, payload, socket) do

  #   %{"username" => username, "isMonitor" => isMonitor} = payload
  #   socket = socket |> assign(session_code: code, channel: channel)

  #   # 1) verify session code validity
  #   if SessionMonitor.exists_session?(code) do
  #     session = SessionMonitor.get_session(code)

  #     # 2) verify user authorization
  #     if isMonitor do
  #       # if it's a Monitor, verify their authorization towards the session, i.e., if the Session belongs to them
  #       if SessionMonitor.session_belongs_to_monitor?(session.code, username) do
  #         # 3) add user to session channel and respond
  #         {:ok, socket}
  #       else
  #         # QuicWeb.Endpoint.broadcast(channel <> ":monitor", "disconnect", %{})
  #         {:error, %{reason: "You can't access Sessions that don't belong to you!"}}
  #       end

  #     # If it's a Participant, insert them in the DB in the associated Session
  #     else
  #       if SessionParticipant.participant_already_in_session?(username, session.code) do
  #         {:ok, socket}
  #       else
  #         # 3) add user to session channel and respond
  #         {:ok, participant} = SessionParticipant.create_participant(session, username)
  #         socket = assign(socket, :participant, participant)
  #         Phoenix.PubSub.broadcast(Quic.PubSub, socket.assigns.channel <> ":participant:" <> participant.name, {"joined_session", %{"participant" => participant}})
  #         Phoenix.PubSub.broadcast(Quic.PubSub, socket.assigns.channel <> ":monitor", {"participant_joined", %{"name" => participant.name}})
  #         {:ok, socket}
  #       end
  #     end


  #   # if the code isn't valid, i.e., the session isn't open
  #   else
  #     if isMonitor do
  #       {:ok, socket}
  #     else
  #       Phoenix.PubSub.broadcast(Quic.PubSub, socket.assigns.channel, {"error_joining_session", %{"error" => "Invalid Session Code"}})
  #       # QuicWeb.Endpoint.broadcast("session:#{code}:participant:#{username}", "disconnect", %{})
  #       {:error, %{reason: "Session doesn't exist"}}
  #     end
  #   end

  #   # #send(self(), :after_join)

  #   # if authorized?(payload) do
  #   #   {:ok, assign(socket, :session_id, id)}
  #   # else
  #   #   {:error, %{reason: "unauthorized"}}
  #   # end
  # end


  @impl true
  def handle_in("participant_submitted_answer", %{"participant_id" => participant_id, "session_code" => code, "question_id" => question_id, "selected_answer" => answer_id}, socket) do

    # verify if participant is on the session
    if SessionParticipant.participant_already_in_session?(participant_id, code) do

      # update participant's current question
      SessionParticipant.update_participant_current_question(participant_id)

      # evaluate participant's submission
      results = SessionParticipant.assess_submission(participant_id, question_id, answer_id)

      # update data base with Participant's results
      SessionParticipant.update_participant_results(participant_id, question_id, results)

      # send results to the Participant and Session Monitor
      name = SessionParticipant.get_participant_name(participant_id)
      Phoenix.PubSub.broadcast(Quic.PubSub, "session:" <> code <> ":monitor", {"participant_submitted_answer", %{"participant_name" => name, "answer" => results}})
      #Phoenix.PubSub.broadcast(Quic.PubSub, "session:" <> code <> ":participant:" <> participant_id, {"submission_results", %{"answer" => results}})

      {:reply, {:ok, %{"answer" => results}}, socket}
    else
      {:reply, :error, socket}
    end

  end


  @impl true
  def handle_in("monitor-start-session", %{"session_code" => code, "session_id" => session_id, "email" => email}, socket) do
    if SessionMonitor.exists_session_with_id?(session_id) and SessionMonitor.session_belongs_to_monitor?(session_id, email) do
      case SessionMonitor.start_session(session_id) do
        {:ok, first_question} ->
          Phoenix.PubSub.broadcast(Quic.PubSub, "session:" <> code, {"session-started", %{"question" => first_question}})
          {:reply, :ok, socket}

        {:error, _} ->
          # Phoenix.PubSub.broadcast(Quic.PubSub, "session:" <> code <> ":monitor", {"monitor-unable-to-start-session", %{"msg" => "Error Starting Session"}})
          {:reply, :error, socket}
      end
    end
  end

  @impl true
  def handle_in("monitor-close-session", %{"session_code" => code, "session_id" => session_id, "email" => email}, socket) do
    if SessionMonitor.exists_session_with_id?(session_id) and SessionMonitor.session_belongs_to_monitor?(session_id, email) do
      case SessionMonitor.close_session(session_id) do
        {:ok, _} ->
          # Phoenix.PubSub.broadcast(Quic.PubSub, "session:" <> code <> ":monitor", "monitor-session-closed")
          Phoenix.PubSub.broadcast(Quic.PubSub, "session:" <> code, "monitor-closed-session")
          {:reply, :ok, socket}

        {:error, _} ->
          # Phoenix.PubSub.broadcast(Quic.PubSub, "session:" <> code <> ":monitor", "monitor-unable-to-close-session")
          {:reply, :error, socket}
      end
    end
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
