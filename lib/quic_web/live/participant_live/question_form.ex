defmodule QuicWeb.ParticipantLive.QuestionForm do
  alias Quic.Participants
  use QuicWeb, :live_view

  @impl true
  def mount(%{"code" => code, "id" => participant_id}, _session, socket) do
    Phoenix.PubSub.subscribe(Quic.PubSub, "session:" <> code <> ":participant:" <> participant_id)
    Phoenix.PubSub.subscribe(Quic.PubSub, "session:" <> code)

    {:ok, socket
        |> assign(participant: Participants.get_participant!(participant_id))
        |> assign(:page_title, "Live Session #{code}")
        |> assign(:session_code, code)
        |> assign(:monitor_msg, "")}
  end


  @impl true
  def handle_info({"monitor_message", %{"message" => msg}}, socket) do
    {:noreply, assign(socket, :monitor_msg, msg)}
  end

  def handle_info(_, socket), do: {:noreply, socket}
end
