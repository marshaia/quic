defmodule QuicWeb.ParticipantLive.EnterSessionForm do
  use QuicWeb, :live_view


  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(Quic.PubSub, "session:")
    {:ok, socket
          |> assign(:page_title, "Join Session")
          |> assign(:message, "")
          |> assign(:code, "")
          |> assign(:changeset,  %{"code" => ""})}
  end

  def handle_event("validate", %{"code" => code}, socket) do
    {:noreply, assign(socket, :code, code)}
  end

  def handle_event("save", %{"code" => code}, socket) do
    {:noreply, assign(socket, :code, code)}
  end


  def handle_info({"joined_session", %{"session" => session}}, socket) do
    {:noreply, assign(socket, :message, session)}
  end

  def handle_info(_, socket), do: {:noreply, socket}





end
