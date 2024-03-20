defmodule QuicWeb.ParticipantLive.QuestionForm do
  alias Quic.Participants
  use QuicWeb, :live_view

  def mount(%{"code" => code, "id" => participant_id}, _session, socket) do
    {:ok, socket
        |> assign(participant: Participants.get_participant!(participant_id))
        |> assign(:page_title, "Session #{code}")
        |> assign(:session_code, code)}
  end
end
