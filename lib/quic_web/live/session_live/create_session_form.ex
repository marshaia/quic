defmodule QuicWeb.SessionLive.CreateSessionForm do
  alias Quic.Quizzes
  use QuicWeb, :author_live_view

  alias Quic.Sessions
  alias Quic.Sessions.Session


  @impl true
  def mount(%{"quiz_id" => quiz_id}, _session, socket) do
    if Quizzes.is_allowed_to_access?(quiz_id, socket.assigns.current_author) do
      session = Sessions.change_session(%Session{})
      |> Ecto.Changeset.put_assoc(:monitor, socket.assigns.current_author)
      |> Ecto.Changeset.put_assoc(:quiz, Quizzes.get_quiz!(quiz_id))
      |> Ecto.Changeset.put_assoc(:participants, [])

      {:ok, socket
            |> assign(:changeset, session)
            |> assign(:quiz, Quizzes.get_quiz!(quiz_id))
            |> assign(:page_title, "New Session")}

    else
      {:ok, socket
            |> put_flash(:error, "You can only create Sessions with Quizzes shared with you!")
            |> push_navigate(to: ~p"/sessions")}
    end


  end


  @impl true
  def mount(_params, _session, socket) do
    session = Sessions.change_session(%Session{})
      |> Ecto.Changeset.put_assoc(:monitor, socket.assigns.current_author)
      #|> Ecto.Changeset.put_assoc(:quiz, nil)
      |> Ecto.Changeset.put_assoc(:participants, [])

    {:ok, socket
          |> assign(:changeset, session)
          |> assign(:page_title, "New Session")}
  end

  @impl true
  def handle_event("validate", %{"session" => session_params}, socket) do
    changeset = Sessions.change_session(%Session{}, session_params)
                |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"session" => session_params}, socket) do
    case Sessions.create_session(session_params) do
      {:ok, session} ->
        #notify_parent({:saved, session})

        {:noreply,
         socket
         |> put_flash(:info, "Session created successfully")
         |> push_navigate(to: ~p"/sessions/#{session.id}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
