defmodule QuicWeb.ParticipantLive.WaitRoom do
  use QuicWeb, :live_view

  alias Quic.Participants
  alias Quic.Sessions

  @impl true
  def mount(%{"code" => code, "id" => participant_id}, _session, socket) do
    Phoenix.PubSub.subscribe(Quic.PubSub, "session:" <> code <> ":participant:" <> participant_id)
    Phoenix.PubSub.subscribe(Quic.PubSub, "session:" <> code)

    case Sessions.get_open_session_by_code(code) do
      nil -> {:ok, socket |> put_flash(:error, "Invalid Session code or Session doesn't exist") |> redirect(to: ~p"/")}
      session ->
        participant = Participants.participant_belongs_to_session?(participant_id, session.id)
        if participant === nil do
          {:ok, socket |> put_flash(:error, "Participant doesn't exist or doesn't belong to Session") |> redirect(to: ~p"/")}

        else
          {:ok, socket
            |> assign(:participant, Participants.get_participant!(participant_id))
            |> assign(:page_title, "Session #{code}")
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
              |> redirect(to: ~p"/live-session/#{socket.assigns.participant.id}/question/#{question.position}")}
  end

  @impl true
  def handle_info("monitor-closed-session", socket) do
    code = socket.assigns.session_code
    Phoenix.PubSub.unsubscribe(Quic.PubSub, "session:" <> code)
    Phoenix.PubSub.unsubscribe(Quic.PubSub, "session:" <> code <> ":participant:" <> socket.assigns.participant.id)

    {:noreply, socket
              |> put_flash(:info, "This Session has been closed by the Monitor. Hope you enjoyed it!")
              |> redirect(to: ~p"/")}
  end

  @impl true
  def handle_info(_, socket), do: {:noreply, socket}

end
