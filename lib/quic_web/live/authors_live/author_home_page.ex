defmodule QuicWeb.AuthorHomePage do
  use QuicWeb, :author_live_view

  alias Quic.Quizzes

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:searched_quizzes, Quizzes.filter_public_quizzes(""))}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, socket |> assign(:page_title, "Home") |> assign(:current_path, "/authors")}
  end

  # QUIZZES
  @impl true
  def handle_event("changed_quiz", %{"input" => input}, socket) do
    quizzes = Quizzes.filter_public_quizzes(input)
    {:noreply, assign(socket, searched_quizzes: quizzes)}
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
  def handle_event("ignore", _params, socket) do
    {:noreply, socket}
  end
end
