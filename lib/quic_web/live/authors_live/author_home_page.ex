defmodule QuicWeb.AuthorHomePage do
  use QuicWeb, :author_live_view

  alias Quic.Accounts
  alias Quic.Quizzes

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket
      |> assign(:page_title, "Home")
      |> assign(:current_path, "/authors")
      |> assign(:searched_users, %{})
      |> assign(:searched_quizzes, %{})}
  end


  # AUTHORS
  @impl true
  def handle_event("changed_author", %{"input" => input}, socket) do
    if String.length(input) === 0 do
      {:noreply, assign(socket, searched_users: [])}
    else
      users = Accounts.get_author_by_name_or_username(input)
      result = Enum.reject(users, fn user -> user.username === socket.assigns.current_author.username end)
      {:noreply, assign(socket, searched_users: result)}
    end
  end

  @impl true
  def handle_event("clicked_user", %{"username" => username} = _params, socket) do
    case Accounts.get_author_by_username(username) do
      nil -> {:noreply, socket |> put_flash(:error, "Invalid Author")}
      author -> {:noreply, socket |> redirect(to: ~p"/authors/profile/#{author.id}")}
    end
  end


  # QUIZZES
  @impl true
  def handle_event("changed_quiz", %{"input" => input}, socket) do
    if String.length(input) === 0 do
      {:noreply, assign(socket, searched_quizzes: [])}
    else
      quizzes = Quizzes.filter_public_quizzes(input)
      {:noreply, assign(socket, searched_quizzes: quizzes)}
    end
  end

  @impl true
  def handle_event("clicked_quiz", %{"id" => quiz_id} = _params, socket) do
    try do
      Quizzes.get_quiz!(quiz_id)
      {:noreply, socket |> redirect(to: ~p"/quizzes/#{quiz_id}")}
    rescue
      _ ->  {:noreply, socket |> put_flash(:error, "Invalid Quiz")}
    end
  end



  @impl true
  def handle_event("save", _params, socket) do
    {:noreply, socket}
  end
end
