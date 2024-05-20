defmodule QuicWeb.SessionLive.FullScreenControls do
  alias Quic.Quizzes
  use QuicWeb, :live_view

  alias Quic.Sessions

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    session = Sessions.get_session!(id)
    if session.type === :monitor_paced do
      quiz = Quizzes.get_quiz!(session.quiz.id)

      socket = push_event(socket, "join_session", %{code: session.code, email: socket.assigns.current_author.email, session_id: session.id})

      Phoenix.PubSub.subscribe(Quic.PubSub, "session:" <> session.code)
      Phoenix.PubSub.subscribe(Quic.PubSub, "session:" <> session.code <> ":monitor")

      {:noreply, socket
                |> assign(:quiz, quiz)
                |> assign(:session, session)
                |> assign(:page_title, "Session #{session.code}")
                |> assign(:current_path, "/sessions/#{id}/full-screen")
                |> assign(:participants, Sessions.get_session_participants(id))}

              else
      {:noreply, socket
                |> put_flash(:error, "Session is not of type Monitor Paced!")
                |> redirect(to: ~p"/sessions")}
    end
  end


  @impl true
  def handle_event("next_question", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("back_to_session", _params, socket) do
    {:noreply, socket |> redirect(to: ~p"/sessions/#{socket.assigns.session.id}")}
  end

  @impl true
  def handle_event("start_session_btn", _payload, socket) do
    {:noreply, socket |> push_event("start_session", %{session_id: socket.assigns.session.id, code: socket.assigns.session.code, email: socket.assigns.current_author.email})}
  end

  @impl true
  def handle_event("close_session_btn", _payload, socket) do
    {:noreply, socket |> push_event("close_session", %{session_id: socket.assigns.session.id, code: socket.assigns.session.code, email: socket.assigns.current_author.email})}
  end



  # SERVER MESSAGES
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

end
