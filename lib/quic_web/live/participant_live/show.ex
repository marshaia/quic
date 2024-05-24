defmodule QuicWeb.ParticipantLive.Show do
  use QuicWeb, :author_live_view

  alias Quic.Participants
  alias Quic.Sessions

  require Logger

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"session_id" => session_id, "participant_id" => participant_id}, _, socket) do
    participant = Participants.get_participant!(participant_id)
    Phoenix.PubSub.subscribe(Quic.PubSub, "session:" <> participant.session.code <> ":participant:" <> participant_id)

    {:noreply,
     socket
     |> assign(:current_path, "/session/#{session_id}/participants/#{participant_id}")
     |> assign(:page_title, "Show Participant")
     |> assign(:participant, participant)
     |> assign(:quiz, Sessions.get_session_quiz(session_id))
     |> assign(:back, "/sessions/#{session_id}")}
  end


  @impl true
  def handle_info({"submission_results", _}, socket) do
    {:noreply, socket |> assign(:participant, Participants.get_participant!(socket.assigns.participant.id))}
  end

  def handle_info(_, socket), do: {:noreply, socket}


  def progress_percentage(participant_question, quiz_total_questions) when quiz_total_questions > 0 do
    Float.round((participant_question / quiz_total_questions) * 100, 2)
    #   steps = div(100, quiz_total_questions)
    #   res = steps * participant_question
  end

end
