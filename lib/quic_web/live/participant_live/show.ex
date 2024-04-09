defmodule QuicWeb.ParticipantLive.Show do
  use QuicWeb, :author_live_view

  alias Quic.Participants

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"session_id" => session_id, "participant_id" => participant_id}, _, socket) do
    {:noreply,
     socket
     |> assign(:current_path, "/session/#{session_id}/participants/#{participant_id}")
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:participant, Participants.get_participant!(participant_id))
     |> assign(:session_id, session_id)
     |> assign(:back, "/sessions/#{session_id}")}
  end

  defp page_title(:show), do: "Show Participant"
  # defp page_title(:edit), do: "Edit Participant"
end
