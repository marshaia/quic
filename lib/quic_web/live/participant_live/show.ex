defmodule QuicWeb.ParticipantLive.Show do
  use QuicWeb, :author_live_view

  alias Quic.Participants
  alias Quic.Parameters
  alias QuicWeb.QuicWebAux

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"session_id" => session_id, "participant_id" => participant_id}, _, socket) do
    participant = Participants.participant_belongs_to_session?(participant_id, session_id)

    if participant === nil do
      {:noreply, socket |> put_flash(:error, "Participant doesn't exist or doesn't belong to Session") |> redirect(to: ~p"/sessions/#{session_id}")}
    else
      Phoenix.PubSub.subscribe(Quic.PubSub, "session:" <> participant.session.code <> ":participant:" <> participant_id)

      {:noreply, socket
                |> assign(:current_path, "/session/#{session_id}/participants/#{participant_id}")
                |> assign(:page_title, "Session - Show Participant")
                |> assign(:participant, participant)
                |> assign(:quiz, participant.session.quiz)
                |> assign(:back, "/sessions/#{session_id}")}
    end
  end


  @impl true
  def handle_info({"submission_results", _}, socket) do
    {:noreply, socket |> assign(:participant, Participants.get_participant!(socket.assigns.participant.id))}
  end

  def handle_info(_, socket), do: {:noreply, socket}

end
