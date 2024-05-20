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

end
