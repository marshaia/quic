defmodule QuicWeb.ParticipantLive.QuestionForm do

  use QuicWeb, :live_view

  alias Quic.Participants
  alias Quic.Sessions
  alias Quic.Questions


  @impl true
  def mount(%{"participant_id" => participant_id, "question_id" => question_id}, _session, socket) do
    participant = Participants.get_participant!(participant_id)
    code = Participants.get_participant_session_code!(participant_id)

    Phoenix.PubSub.subscribe(Quic.PubSub, "session:" <> code <> ":participant:" <> participant_id)
    Phoenix.PubSub.subscribe(Quic.PubSub, "session:" <> code)

    case Sessions.get_session_by_code(code) do
      nil -> {:ok, redirect(socket, to: ~p"/")}
      session ->
        if session.status !== :open do
          {:ok, redirect(socket, to: ~p"/")}
        else
          {:ok, socket
          |> assign(:session_code, code)
          |> assign(participant: participant)
          |> assign(:selected_answer, nil)
          |> assign(:page_title, "Session #{code} - Question ?")
          |> assign(:question, Questions.get_question!(question_id))}
        end
    end
  end


  # SELECTED ANSWER
  @impl true
  def handle_event("selected-answer", %{"id" => answer_id}, socket) do
    {:noreply, socket
              |> assign(:selected_answer, answer_id)}
  end


  # SESSION CHANNEL MESSAGES
  @impl true
  def handle_info({"monitor_message", %{"message" => msg}}, socket) do
    {:noreply, assign(socket, :monitor_msg, msg)}
  end

  @impl true
  def handle_info("monitor-closed-session", socket) do
    {:noreply, socket
              |> put_flash(:info, "This Session has been closed by the Monitor. Hope you enjoyed it!")
              |> redirect(to: ~p"/")}
  end

  def handle_info(_, socket), do: {:noreply, socket}
end
