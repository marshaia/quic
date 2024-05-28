defmodule QuicWeb.QuizLive.Index do
  use QuicWeb, :author_live_view

  alias Quic.Quizzes
  alias Quic.Quizzes.Quiz

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :quizzes, Quizzes.list_all_author_available_quizzes(socket.assigns.current_author.id))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, socket |> assign(:current_path, "/quizzes") |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Quiz")
    |> assign(:quiz, %Quiz{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Quizzes")
    |> assign(:quiz, nil)
    |> assign(:current_path, "/quizzes")
  end

  @impl true
  def handle_info({QuicWeb.QuizLive.FormComponent, {:saved, _}}, socket) do
    {:noreply, assign(socket, :quizzes, Quizzes.list_all_author_quizzes(socket.assigns.current_author.id))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    quiz = Quizzes.get_quiz!(id)
    {:ok, _} = Quizzes.delete_quiz(quiz)

    {:noreply, assign(socket, :quizzes, Quizzes.list_all_author_quizzes(socket.assigns.current_author.id))}
  end

  @impl true
  def handle_event("clicked_quiz", %{"id" => id}, socket) do
    {:noreply, redirect(socket, to: "/quizzes/#{id}")}
  end

  @impl true
  def handle_event("form_quiz_changed", %{"quiz_input" => input}, socket) do
    {:noreply, socket |> assign(:quizzes, filter_author_quizzes(socket.assigns.current_author.id, input))}
  end


  defp filter_author_quizzes(author_id, input) do
    if String.length(input) === 0 do
      Quizzes.list_all_author_available_quizzes(author_id)
    else
      Quizzes.list_all_author_quizzes_filtered(author_id, input)
    end
  end
end
