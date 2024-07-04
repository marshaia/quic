defmodule QuicWeb.SessionLive.CreateSessionForm do
  use QuicWeb, :author_live_view

  alias Quic.Quizzes
  alias Quic.Sessions
  alias QuicWeb.QuicWebAux

  @impl true
  def mount(%{"quiz_id" => quiz_id}, _session, socket) do
    if Quizzes.is_allowed_to_access?(quiz_id, socket.assigns.current_author) do
      {:ok, socket
        |> assign(:step, 1)
        |> assign(:quiz, Quizzes.get_quiz!(quiz_id))
        |> assign(:session_type, :monitor_paced)
        |> assign(:filtered_quizzes, Quizzes.list_all_author_quizzes(socket.assigns.current_author.id))
        |> assign(:page_title, "New Session")
        |> assign(:current_path, "/sessions/new/quiz/#{quiz_id}")
        |> assign(:back, "/quizzes/#{quiz_id}")
        |> assign(:changeset, %{"immediate_feedback" => false, "final_feedback" => false})}

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
      |> assign(:session_type, :monitor_paced)
      |> assign(:page_title, "New Session")
      |> assign(:current_path, "/sessions/new")
      |> assign(:back, "/sessions")
      |> assign(:filtered_quizzes, Enum.reject(Quizzes.list_all_author_quizzes(socket.assigns.current_author.id), fn quiz -> Enum.count(quiz.questions) === 0 end))
      |> assign(:changeset, %{"immediate_feedback" => false, "final_feedback" => false})}
  end


  @impl true
  def handle_event("form_type_changed", %{"type" => type}, socket) do
    {:noreply, socket |> assign(session_type: String.to_atom(type))}
  end

  @impl true
  def handle_event("form_quiz_changed", %{"quiz_input" => input}, socket) do
    {:noreply, socket |> assign(:filtered_quizzes, filter_author_quizzes(socket.assigns.current_author.id, input))}
  end

  @impl true
  def handle_event("clicked_quiz", %{"id" => quiz_id} = _params, socket) do
    quiz = Quizzes.get_quiz!(quiz_id)
    if Enum.count(quiz.questions) === 0 do
      {:noreply, socket |> put_flash(:error, "You can't chose a quiz with no questions!")}
    else
      {:noreply, socket
        |> assign(quiz: Quizzes.get_quiz!(quiz_id))
        |> assign(:filtered_quizzes, filter_author_quizzes(socket.assigns.current_author.id, ""))}
    end

  end
  @impl true
  def handle_event("deselect_quiz", _params, socket) do
    {:noreply, socket |> assign(quiz: nil)}
  end

  @impl true
  def handle_event("validate_parameters", %{"immediate_feedback" => immediate, "final_feedback" => final}, socket) do
    {:noreply, socket |> assign(:changeset, %{"immediate_feedback" => immediate === "true", "final_feedback" => final === "true"})}
  end

  @impl true
  def handle_event("save", _params, socket) do
    if socket.assigns.quiz === nil || socket.assigns.session_type === nil do
      {:noreply, socket |> put_flash(:error, "A Session needs to have both a Type and a Quiz associated!")}

    else
      session_params = Map.merge(%{"type" => socket.assigns.session_type}, socket.assigns.changeset)
      case Sessions.create_session(session_params, socket.assigns.current_author, socket.assigns.quiz) do
        {:ok, session} ->
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
    if socket.assigns.step < 4 do
      {:noreply, socket |> assign(:step, socket.assigns.step + 1)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("ignore", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("previous_step", _params, socket) do
    if socket.assigns.step > 1 do
      {:noreply, socket |> assign(:step, socket.assigns.step - 1)}
    else
      {:noreply, socket}
    end
  end

  def filter_author_quizzes(author_id, input) do
    if String.length(input) === 0 do
      Enum.reject(Quizzes.list_all_author_quizzes(author_id), fn quiz -> Enum.count(quiz.questions) === 0 end)
    else
      Enum.reject(Quizzes.filter_author_quizzes(author_id, input), fn quiz -> Enum.count(quiz.questions) === 0 end)
    end
  end

end
