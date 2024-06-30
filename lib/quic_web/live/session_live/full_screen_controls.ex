defmodule QuicWeb.SessionLive.FullScreenControls do
  use QuicWeb, :live_view

  alias Quic.Sessions
  alias QuicWeb.QuicWebAux

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    if Sessions.exists_session_with_id?(id) && Sessions.is_owner?(id, socket.assigns.current_author) do
      session = Sessions.get_session!(id)
      if session.type === :monitor_paced do
        quiz = session.quiz

        socket = push_event(socket, "join_session", %{code: session.code, email: socket.assigns.current_author.email, session_id: session.id})
        Phoenix.PubSub.subscribe(Quic.PubSub, "session:" <> session.code)
        Phoenix.PubSub.subscribe(Quic.PubSub, "session:" <> session.code <> ":monitor")

        {:noreply, socket
          |> assign(:quiz, quiz)
          |> assign(:session, session)
          |> assign(:page_title, "Session #{session.code}")
          |> assign(:current_path, "/sessions/#{id}/full-screen")
          |> assign(:participants, Sessions.get_session_participants(id))
          |> assign(:show_correct_answers, false)}

      else
        {:noreply, socket |> put_flash(:error, "Session is not of type Monitor Paced!") |> redirect(to: ~p"/sessions")}
      end

    else
      {:noreply, socket |> put_flash(:error, "Invalid Session") |> redirect(to: ~p"/sessions")}
    end
  end


  @impl true
  def handle_event("next_question", _params, socket) do
    {:noreply, socket |> push_event("next_question", %{code: socket.assigns.session.code, session_id: socket.assigns.session.id, email: socket.assigns.current_author.email})}
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

  @impl true
  def handle_event("toggle_correct_answers", _params, socket) do
    {:noreply, socket |> assign(:show_correct_answers, !socket.assigns.show_correct_answers)}
  end



  # SERVER MESSAGES
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
  def handle_info({"next_question", _params}, socket) do
    {:noreply, socket
      |> assign(:session, Sessions.get_session!(socket.assigns.session.id))
      |> assign(:show_correct_answers, false)
      |> put_flash(:info, "Next question")}
  end

  @impl true
  def handle_info("error-next-question", socket) do
    {:noreply, socket |> put_flash(:error, "Couldn't continue to the next question.")}
  end


  @impl true
  def handle_info(_, socket), do: {:noreply, socket}

end
