defmodule QuicWeb.ParticipantLive.EnterSessionForm do
  use QuicWeb, :live_view


  def mount(_params, _session, socket) do
    {:ok, socket
          |> assign(:page_title, "Join Session")
          |> assign(:code, "")
          |> assign(:changeset,  %{"code" => ""})}
  end

  def handle_event("validate", %{"code" => code}, socket) do
    {:noreply, assign(socket, :code, code)}
  end

  def handle_event("save", %{"code" => code}, socket) do
    {:noreply, assign(socket, :code, code)}
  end



end
