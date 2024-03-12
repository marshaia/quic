defmodule QuicWeb.SessionChannel do
  use QuicWeb, :channel

  @impl true
  def join("session:" <> id, _payload, socket) do
    # verify authorization (monitor vs participant)
    # verify session code validity
    # add user to session channel and respond
    #send(self(), :after_join)
    socket = socket |> assign(session_id: id, channel: "session:")

    Phoenix.PubSub.broadcast(Quic.PubSub, socket.assigns.channel, {"joined_session", %{"session" => "joined :D"}})

    {:ok, socket}
    # if authorized?(payload) do
    #   {:ok, assign(socket, :session_id, id)}
    # else
    #   {:error, %{reason: "unauthorized"}}
    # end
  end

  # @impl true
  # def handle_in(:after_join, _payload, socket) do
  #   broadcast(socket, "server_message", %{body: "joined"})
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
end
