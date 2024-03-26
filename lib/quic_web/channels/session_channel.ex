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
        if SessionMonitor.session_belongs_to_monitor?(session, username) do
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
          Phoenix.PubSub.broadcast(Quic.PubSub, socket.assigns.channel <> ":monitor", {"participant_joined"})
          {:ok, socket}
        end
      end


    # if the code isn't valid
    else
      Phoenix.PubSub.broadcast(Quic.PubSub, socket.assigns.channel, {"error_joining_session", %{"error" => "Invalid Session Code"}})
      # QuicWeb.Endpoint.broadcast("session:#{code}:participant:#{username}", "disconnect", %{})
      {:error, %{reason: "Session doesn't exist"}}
    end

    # #send(self(), :after_join)

    # if authorized?(payload) do
    #   {:ok, assign(socket, :session_id, id)}
    # else
    #   {:error, %{reason: "unauthorized"}}
    # end
  end


  @impl true
  def handle_in("participant_msg_to_monitor", %{"participant_id" => id, "session_code" => code, "message" => msg}, socket) do
    name = SessionParticipant.get_participant_name(id)
    Phoenix.PubSub.broadcast(Quic.PubSub, "session:" <> code <> ":monitor", {"participant_message", %{"participant_name" => name, "message" => msg}})
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
