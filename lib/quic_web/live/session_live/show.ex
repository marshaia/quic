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
              |> assign(:session, session)
              |> assign(:page_title, "Show Session")
              |> assign(:current_path, "/sessions/#{id}")
              |> assign(:participants, Sessions.get_session_participants(id))
              |> assign(:selected_view, :participants)}
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

  @impl true
  def handle_event("next_question", _params, socket) do
    {:noreply, socket |> push_event("next_question", %{code: socket.assigns.session.code, session_id: socket.assigns.session.id, email: socket.assigns.current_author.email})}
  end

  @impl true
  def handle_event("change_selected_view", %{"view" => view}, socket) do
    {:noreply, socket |> assign(:selected_view, String.to_atom(view))}
  end



  # Session Channel Events
  @impl true
  def handle_info({"participant_submitted_answer", %{"participant_name" => username, "answer" => answer}}, socket) do
    {:noreply, socket
              |> assign(:participants, Sessions.get_session_participants(socket.assigns.session.id))
              |> put_flash(:info, "Participant #{username} submitted answer #{answer}")}
  end

  @impl true
  def handle_info("participant_joined", socket) do
    {:noreply, socket |> assign(:participants, Sessions.get_session_participants(socket.assigns.session.id))}
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
  def handle_info({"next-question", _params}, socket) do
    {:noreply, socket
              |> assign(:session, Sessions.get_session!(socket.assigns.session.id))
              |> put_flash(:info, "Next question")}
  end

  @impl true
  def handle_info("error-next-question", socket) do
    {:noreply, socket |> put_flash(:error, "Couldn't continue to the next question.")}
  end

  @impl true
  def handle_info(_, socket), do: {:noreply, socket}



  def session_status_translate(status) do
    case status do
      :open -> "OPEN"
      :on_going -> "ON GOING"
      :closed -> "CLOSED"
    end
  end

end
