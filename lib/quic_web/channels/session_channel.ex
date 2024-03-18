defmodule QuicWeb.SessionChannel do
  use QuicWeb, :channel

  alias QuicWeb.SessionServer

  @impl true
  def join("session:" <> id = channel, _payload, socket) do
    # verify session code validity
    # verify authorization (monitor vs participant)
    # add user to session channel and respond
    socket = socket |> assign(session_id: id, channel: channel)

    #send(self(), :after_join)
    if id === "ASDFG" do
      Phoenix.PubSub.broadcast(Quic.PubSub, socket.assigns.channel, {"joined_session", %{"session" => "joined session - #{id}"}})
      SessionServer.start_session(id)
    else
      Phoenix.PubSub.broadcast(Quic.PubSub, socket.assigns.channel, {"error_joining_session", %{"error" => "invalid session code"}})
    end

    {:ok, socket}
    # if authorized?(payload) do
    #   {:ok, assign(socket, :session_id, id)}
    # else
    #   {:error, %{reason: "unauthorized"}}
    # end
  end

  # @impl true
  # def handle_info(:after_join, socket) do
  #   # broadcast(socket, "server_message", %{body: "joined"})
  #   {:noreply, socket}
  # end

  # def handle_info(_, socket), do: {:noreply, socket}


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
