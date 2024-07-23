defmodule QuicWeb.SessionLive.Show do
  use QuicWeb, :author_live_view

  alias Quic.Sessions
  alias Quic.Parameters
  alias QuicWeb.QuicWebAux

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    if Sessions.exists_session_with_id?(id) && Sessions.is_owner?(id, socket.assigns.current_author) do
      session = Sessions.get_session!(id)
      socket = push_event(socket, "join_session", %{code: session.code, email: socket.assigns.current_author.email, session_id: session.id})
      Phoenix.PubSub.subscribe(Quic.PubSub, "session:" <> session.code)
      Phoenix.PubSub.subscribe(Quic.PubSub, "session:" <> session.code <> ":monitor")

      {:noreply, socket
        |> assign(:session, session)
        |> assign(:quiz, session.quiz)
        |> assign(:page_title, "Show Session")
        |> assign(:current_path, "/sessions/#{id}")
        |> assign(:participants, Sessions.get_session_participants(id))
        |> assign(:selected_view, :participants)
        |> assign(:stats_filter, :participants)
        |> assign(:downloading, false)}

    else
      {:noreply, socket |> put_flash(:error, "Invalid Session") |> redirect(to: ~p"/sessions")}
    end
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

  @impl true
  def handle_event("change_stats_filter", %{"filter" => filter}, socket) do
    {:noreply, socket |> assign(:stats_filter, String.to_atom(filter))}
  end

  @impl true
  def handle_event("download", _params, socket) do
    # orientation = if Enum.count(socket.assigns.session.quiz.questions) > 12, do: "landscape", else: "portrait"
    code = socket.assigns.session.code
    {:noreply, socket
      |> assign(:downloading, true)
      |> push_event("download_page", %{file_name: "session_" <> code <> "_results", html_element: "participant_statistics_table", is_table: true})}
      #|> push_event("participant_stats", %{file_name: "session_" <> code <> "_results", orientation: orientation})}
  end

  @impl true
  def handle_event("finished_download", _parmas, socket) do
    {:noreply, socket |> assign(:downloading, false)}
  end



  # Session Channel Events
  @impl true
  def handle_info("participant_submitted_answer", socket) do
    socket = send_update_points(socket)
    {:noreply, socket |> assign(:participants, Sessions.get_session_participants(socket.assigns.session.id))}
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
  def handle_info({"next_question", _params}, socket) do
    {:noreply, socket
              |> assign(:session, Sessions.get_session!(socket.assigns.session.id))
              |> assign(:participants, Sessions.get_session_participants(socket.assigns.session.id))
              |> put_flash(:info, "Next question")}
  end

  @impl true
  def handle_info("error-next-question", socket) do
    {:noreply, socket |> put_flash(:error, "Couldn't continue to the next question.")}
  end

  @impl true
  def handle_info(_, socket), do: {:noreply, socket}


  defp send_update_points(socket) do
    session_id = socket.assigns.session.id
    questions = socket.assigns.quiz.questions

    Enum.reduce(questions, socket, fn question, acc ->
      points = Sessions.calculate_quiz_question_stats(session_id, question.id)
      acc = push_event(acc, "update-points", %{
        id: "doughnut-chart-question-#{question.id}",
        points: points
      })
      acc
    end)
  end
end
