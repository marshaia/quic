defmodule QuicWeb.QuestionAnswerLive.Index do
  use QuicWeb, :live_view

  alias Quic.Questions
  alias Quic.Questions.QuestionAnswer

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :question_answers, Questions.list_question_answers())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Question answer")
    |> assign(:question_answer, Questions.get_question_answer!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Question answer")
    |> assign(:question_answer, %QuestionAnswer{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Question answers")
    |> assign(:question_answer, nil)
  end

  @impl true
  def handle_info({QuicWeb.QuestionAnswerLive.FormComponent, {:saved, question_answer}}, socket) do
    {:noreply, stream_insert(socket, :question_answers, question_answer)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    question_answer = Questions.get_question_answer!(id)
    {:ok, _} = Questions.delete_question_answer(question_answer)

    {:noreply, stream_delete(socket, :question_answers, question_answer)}
  end
end
