defmodule QuicWeb.SessionLive.CreateSessionForm do
  use QuicWeb, :author_live_view

  alias Quic.Quizzes
  alias Quic.Sessions
  alias Quic.Sessions.Session

  @impl true
  def mount(%{"quiz_id" => quiz_id}, _session, socket) do
    if Quizzes.is_allowed_to_access?(quiz_id, socket.assigns.current_author) do
      {:ok, socket
            |> assign(:step, 1)
            |> assign(:quiz, Quizzes.get_quiz!(quiz_id))
            |> assign(:session_type, nil)
            |> assign(:filtered_quizzes, Quizzes.list_all_author_quizzes(socket.assigns.current_author.id))
            |> assign(:page_title, "New Session")
            |> assign(:current_path, "/sessions/new/quiz/#{quiz_id}")
            |> assign(:back, "/quizzes/#{quiz_id}")}

    else
      {:ok, socket
            |> put_flash(:error, "You can only create Sessions with Quizzes shared with you!")
            |> push_navigate(to: ~p"/sessions")}
    end


  end


  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket
          |> assign(:step, 1)
          |> assign(:quiz, nil)
          |> assign(:session_type, nil)
          |> assign(:filtered_quizzes, Quizzes.list_all_author_quizzes(socket.assigns.current_author.id))
          |> assign(:page_title, "New Session")
          |> assign(:current_path, "/sessions/new")
          |> assign(:back, "/sessions")}
  end


  @impl true
  def handle_event("form_type_changed", %{"type" => type}, socket) do
    Sessions.change_session(%Session{}, %{type: type}) |> Map.put(:action, :validate)
    {:noreply, socket |> assign(session_type: type)}
  end

  @impl true
  def handle_event("form_quiz_changed", %{"quiz_name" => name}, socket) do
    result = filter_author_quizzes(socket.assigns.current_author.id, name)
    {:noreply, socket |> assign(filtered_quizzes: result)}
  end

  @impl true
  def handle_event("clicked_quiz", %{"id" => quiz_id} = _params, socket) do
    {:noreply, socket
              |> assign(quiz: Quizzes.get_quiz!(quiz_id))
              |> assign(:filtered_quizzes, Quizzes.list_all_author_quizzes(socket.assigns.current_author.id))}
  end
  @impl true
  def handle_event("deselect_quiz", _params, socket) do
    {:noreply, socket |> assign(quiz: nil)}
  end

  @impl true
  def handle_event("save", _params, socket) do
    if socket.assigns.quiz === nil || socket.assigns.session_type === nil do
      {:noreply, socket |> put_flash(:error, "A Session needs to have both a Type and a Quiz associated!")}
    else
      session_params = %{"type" => socket.assigns.session_type}
      case Sessions.create_session(session_params, socket.assigns.current_author, socket.assigns.quiz) do
      {:ok, session} ->
        #notify_parent({:saved, session})

      {:noreply, socket
                |> put_flash(:info, "Session created successfully")
                |> redirect(to: ~p"/sessions/#{session.id}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(:changeset, changeset) |> put_flash(:error, "Something went wrong :(")}
      end
    end

  end


  @impl true
  def handle_event("next_step", _params, socket) do
    if socket.assigns.step < 3 do
      {:noreply, socket |> assign(:step, socket.assigns.step + 1)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("previous_step", _params, socket) do
    if socket.assigns.step > 1 do
      {:noreply, socket |> assign(:step, socket.assigns.step - 1)}
    else
      {:noreply, socket}
    end
  end

  # fazer ao nivel da BD com uma query
  defp filter_author_quizzes(author_id, input) do
    Enum.filter(Quizzes.list_all_author_quizzes(author_id), fn quiz -> String.match?(quiz.name, ~r/#{input}/i) end)
    |> Enum.filter(fn quiz -> String.match?(quiz.description, ~r/#{input}/i) end)
    #|> Enum.filter(fn quiz -> String.match?(quiz.author.display.name, ~r/#{input}/i) end)
  end

end
