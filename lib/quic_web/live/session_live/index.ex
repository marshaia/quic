defmodule QuicWeb.SessionLive.Index do
  use QuicWeb, :author_live_view

  alias Quic.Sessions

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket
          |> assign(:sessions, Sessions.list_all_author_sessions(socket.assigns.current_author.id))
          |> assign(:page_title, "Sessions")}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, socket |> assign(:current_path, "/sessions")}
  end


  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    session = Sessions.get_session!(id)
    {:ok, _} = Sessions.delete_session(session)

    {:noreply, assign(socket, :sessions, Sessions.list_all_author_sessions(socket.assigns.current_author.id))}
  end

  @impl true
  def handle_event("clicked_session", %{"id" => session_id}, socket) do
    {:noreply, redirect(socket, to: "/sessions/#{session_id}")}
  end


  def session_status_color(status) do
    case status do
      :open -> "bg-[var(--green)]"
      :on_going -> "bg-yellow-500"
      :closed -> "bg-red-700"
    end
  end
end
