defmodule QuicWeb.SessionLive.Show do
  use QuicWeb, :author_live_view

  alias Quic.Sessions
  alias QuicWeb.QuicWebAux

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    session = Sessions.get_session!(id)

    socket = push_event(socket, "join_session", %{code: session.code, email: socket.assigns.current_author.email, session_id: session.id})

    Phoenix.PubSub.subscribe(Quic.PubSub, "session:" <> session.code)
    Phoenix.PubSub.subscribe(Quic.PubSub, "session:" <> session.code <> ":monitor")

    {:noreply, socket
              |> assign(:page_title, page_title(socket.assigns.live_action))
              |> assign(:participant_message, "")
              |> assign(:participants, Sessions.get_session_participants(id))
              |> assign(:session, session)
              |> assign(:current_path, "/sessions/#{id}")}
  end



  @impl true
  def handle_event("clicked_participant", %{"id" => participant_id}, socket) do
    {:noreply, redirect(socket, to: "/session/#{socket.assigns.session.id}/participants/#{participant_id}")}
  end

  @impl true
  def handle_event("start-session-btn", _payload, socket) do
    {:noreply, socket |> push_event("start_session", %{session_id: socket.assigns.session.id, code: socket.assigns.session.code, email: socket.assigns.current_author.email})}
  end

  @impl true
  def handle_event("close-session-btn", _payload, socket) do
    {:noreply, socket |> push_event("close_session", %{session_id: socket.assigns.session.id, code: socket.assigns.session.code, email: socket.assigns.current_author.email})}
  end





  # Session Channel Events
  @impl true
  def handle_info({"participant_submitted_answer", %{"participant_name" => username, "answer" => answer}}, socket) do
    {:noreply, socket
              |> assign(:participants, Sessions.get_session_participants(socket.assigns.session.id))
              |> put_flash(:info, "Participant #{username} submitted answer #{answer}")}
  end

  @impl true
  def handle_info({"participant_joined", %{"name" => name}}, socket) do
    {:noreply, socket
              |> put_flash(:info, "#{name} just joined the session!")
              |> assign(:participants, Sessions.get_session_participants(socket.assigns.session.id))}
  end

  @impl true
  def handle_info({"session-started", _params}, socket) do
    {:noreply, socket
              |> assign(:session, Sessions.get_session!(socket.assigns.session.id))
              |> put_flash(:info, "Session started!")}
  end

  @impl true
  def handle_info("error-starting-session", socket) do
    {:noreply, socket |> put_flash(:error, "Something went wrong. Please try again!")}
  end

  @impl true
  def handle_info("monitor-closed-session", socket) do
    {:noreply, socket
              |> assign(:session, Sessions.get_session!(socket.assigns.session.id))
              |> put_flash(:info, "Session closed!")}
  end

  @impl true
  def handle_info("error-closing-session", socket) do
    {:noreply, socket |> put_flash(:error, "Something went wrong. Please try again!")}
  end

  @impl true
  def handle_info(_, socket), do: {:noreply, socket}



  def session_status_color(status) do
    case status do
      :open -> "bg-[var(--green)]"
      :on_going -> "bg-yellow-500"
      :closed -> "bg-red-700"
    end
  end

  def session_status_translate(status) do
    case status do
      :open -> "OPEN"
      :on_going -> "ON GOING"
      :closed -> "CLOSED"
    end
  end


  defp page_title(:show), do: "Show Session"
  defp page_title(:edit), do: "Edit Session"
end
