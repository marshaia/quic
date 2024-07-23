defmodule QuicWeb.QuizLive.ShowSessionQuiz do
  use QuicWeb, :author_live_view

  alias Quic.Sessions

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"session_id" => session_id}, _uri, socket) do
    if Sessions.is_owner?(session_id, socket.assigns.current_author) do
      session = Sessions.get_session!(session_id)
      {:noreply, socket
        |> assign(:page_title, "Show Session Questions")
        |> assign(:session_id, session_id)
        |> assign(:quiz, session.quiz)
        |> assign(:downloading, false)
        |> assign(:show_correct_answers, true)
        |> assign(:current_path, ~p"/sessions/#{session_id}/quiz")}
    else
      {:noreply, socket
        |> put_flash(:error, "You can only access your Sessions")
        |> push_navigate(to: ~p"/sessions")}
    end
  end

  @impl true
  def handle_event("download", _unsigned_params, socket) do
    {:noreply, socket
      |> assign(:downloading, true)
      |> push_event("download_page", %{file_name: "quiz_" <> socket.assigns.quiz.name <> "_filled", html_element: "session_quiz_page", is_table: false})}
  end

  @impl true
  def handle_event("finished_download", _params, socket) do
    {:noreply, socket |> assign(:downloading, false)}
  end

  @impl true
  def handle_event("hide_correct_answers", _params, socket) do
    {:noreply, socket |> assign(:show_correct_answers, false)}
  end

  @impl true
  def handle_event("show_correct_answers", _params, socket) do
    {:noreply, socket |> assign(:show_correct_answers, true)}
  end

end
