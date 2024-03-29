defmodule QuicWeb.QuizLive.Index do
  use QuicWeb, :author_live_view

  alias Quic.Quizzes
  alias Quic.Quizzes.Quiz

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :quizzes, Quizzes.list_all_author_quizzes(socket.assigns.current_author.id))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Quiz")
    |> assign(:quiz, Quizzes.get_quiz!(id))
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
  def handle_info({QuicWeb.QuizLive.FormComponent, {:saved, quiz}}, socket) do
    {:noreply, stream_insert(socket, :quizzes, quiz)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    quiz = Quizzes.get_quiz!(id)
    {:ok, _} = Quizzes.delete_quiz(quiz)

    {:noreply, stream_delete(socket, :quizzes, quiz)}
  end
end
