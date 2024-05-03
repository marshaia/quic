defmodule QuicWeb.ParticipantLive.WaitRoom do

  use QuicWeb, :live_view

  alias Quic.Participants
  alias Quic.Sessions


  @impl true
  def mount(%{"code" => code, "id" => participant_id}, _session, socket) do
    Phoenix.PubSub.subscribe(Quic.PubSub, "session:" <> code <> ":participant:" <> participant_id)
    Phoenix.PubSub.subscribe(Quic.PubSub, "session:" <> code)

    case Sessions.get_open_session_by_code(code) do
      nil -> {:ok, redirect(socket, to: ~p"/")}
      session ->
        if session.status !== :open do
          {:ok, redirect(socket, to: ~p"/")}
        else
          {:ok, socket
          |> assign(participant: Participants.get_participant!(participant_id))
          |> assign(:page_title, "Live Session #{code}")
          |> assign(:session_code, code)}
        end
    end
  end


  @impl true
  def handle_info({"session-started", %{"question" => question}}, socket) do
    code = socket.assigns.session_code
    Phoenix.PubSub.unsubscribe(Quic.PubSub, "session:" <> code)
    Phoenix.PubSub.unsubscribe(Quic.PubSub, "session:" <> code <> ":participant:" <> socket.assigns.participant.id)

    {:noreply, socket
              |> put_flash(:info, "Session started!")
              |> redirect(to: ~p"/live-session/#{socket.assigns.participant.id}/question/#{question.id}")}
  end



  @impl true
  def handle_info(_, socket), do: {:noreply, socket}

end
