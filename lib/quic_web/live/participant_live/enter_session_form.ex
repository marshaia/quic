defmodule QuicWeb.ParticipantLive.EnterSessionForm do
  use QuicWeb, :live_view


  def mount(_params, _session, socket) do
    {:ok, socket
          |> assign(:page_title, "Join Session")
          |> assign(:message, "")
          |> assign(:code, "")
          |> assign(:changeset,  %{"code" => ""})}
  end

  def handle_event("validate", %{"code" => code}, socket) do
    if String.length(code) === 5, do: Phoenix.PubSub.subscribe(Quic.PubSub, "session:" <> String.upcase(code))
    {:noreply, assign(socket, :code, code)}
  end

  def handle_event("save", %{"code" => code}, socket) do
    Phoenix.PubSub.subscribe(Quic.PubSub, "session:" <> String.upcase(code))
    {:noreply, assign(socket, :code, code)}
  end


  def handle_info({"joined_session", %{"session" => session}}, socket) do
    {:noreply, assign(socket, :message, session)}
  end

  def handle_info({"error_joining_session", %{"error" => msg}}, socket) do
    {:noreply, assign(socket, :message, msg)}
  end

  def handle_info(_, socket), do: {:noreply, socket}





end
