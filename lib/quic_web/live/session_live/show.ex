defmodule QuicWeb.SessionLive.Show do
  use QuicWeb, :author_live_view
  require Logger
  alias Quic.Sessions

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    session = Sessions.get_session!(id)
    Phoenix.PubSub.subscribe(Quic.PubSub, "session:" <> session.code)
    Phoenix.PubSub.subscribe(Quic.PubSub, "session:" <> session.code <> ":monitor")

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:participant_message, "")
     |> assign(:session, session)
     |> assign(:current_path, "/sessions/#{id}")}
  end






  # Session Channel Events
  @impl true
  def handle_info({"participant_message", %{"participant_name" => username, "message" => msg}}, socket) do
    {:noreply, socket |> assign(:participant_message, username <> " says: " <> msg)}
  end

  @impl true
  def handle_info({"participant_joined"}, socket) do
    {:noreply, assign(socket, :session, Sessions.get_session!(socket.assigns.session.id))}
  end

  @impl true
  def handle_info({"error_joining_session", %{"error" => msg}}, socket) do
    {:noreply, socket |> put_flash(:error, msg)}
  end

  @impl true
  def handle_info(_, socket), do: {:noreply, socket}



  defp page_title(:show), do: "Show Session"
  defp page_title(:edit), do: "Edit Session"
end
