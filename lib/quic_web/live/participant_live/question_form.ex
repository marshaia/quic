defmodule QuicWeb.ParticipantLive.QuestionForm do
  alias Quic.Participants
  alias Quic.Sessions

  use QuicWeb, :live_view


  @impl true
  def mount(%{"code" => code, "id" => participant_id}, _session, socket) do
    Phoenix.PubSub.subscribe(Quic.PubSub, "session:" <> code <> ":participant:" <> participant_id)
    Phoenix.PubSub.subscribe(Quic.PubSub, "session:" <> code)

    case Sessions.get_session_by_code(code) do
      nil -> {:ok, redirect(socket, to: ~p"/")}
      session ->
        if session.status !== :open do
          {:ok, redirect(socket, to: ~p"/")}
        else
          {:ok, socket
          |> assign(participant: Participants.get_participant!(participant_id))
          |> assign(:page_title, "Live Session #{code}")
          |> assign(:session_code, code)
          |> assign(:monitor_msg, "")}
        end
    end
  end


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
