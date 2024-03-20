defmodule QuicWeb.ParticipantLive.EnterSessionForm do
  use QuicWeb, :live_view


  def mount(_params, _session, socket) do
    {:ok, socket
          |> assign(:page_title, "Join Session")
          |> assign(:participant, %{})
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


  def handle_info({"joined_session", %{"participant" => user}}, socket) do
    {:noreply, socket
              |> assign(:participant, user)
              |> push_navigate(to: ~p"/live-session/#{socket.assigns.code}/#{user.id}", opts: %{participant: user})}
  end

  def handle_info({"error_joining_session", %{"error" => msg}}, socket) do
    {:noreply, socket |> put_flash(:error, msg)}
  end

  def handle_info(_, socket), do: {:noreply, socket}





end
