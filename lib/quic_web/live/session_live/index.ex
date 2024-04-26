defmodule QuicWeb.SessionLive.Index do
  use QuicWeb, :author_live_view

  alias Quic.Sessions
  alias Quic.Sessions.Session

  @impl true
  def mount(_params, _session, socket) do
    #{:ok, stream(socket, :sessions, Sessions.list_all_author_sessions(socket.assigns.current_author.id))}
    #{:ok, stream(socket, :sessions, Sessions.list_sessions())}
    {:ok, assign(socket, :sessions, Sessions.list_all_author_sessions(socket.assigns.current_author.id))} #stream(socket, :sessions, Sessions.list_all_author_sessions(socket.assigns.current_author.id))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Session")
    |> assign(:session, Sessions.get_session!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Session")
    |> assign(:session, %Session{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Sessions")
    |> assign(:session, nil)
    |> assign(:current_path, "/sessions")
  end

  @impl true
  def handle_info({QuicWeb.SessionLive.FormComponent, {:saved, session}}, socket) do
    {:noreply, stream_insert(socket, :sessions, session)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    session = Sessions.get_session!(id)
    {:ok, _} = Sessions.delete_session(session)

    {:noreply, assign(socket, :sessions, Sessions.list_all_author_sessions(socket.assigns.current_author.id))}
  end

  @impl true
  def handle_event("show_page", %{"id" => id}, socket) do
    {:noreply, redirect(socket, to: "/sessions/#{id}")}
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
