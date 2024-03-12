defmodule QuicWeb.TeamLive.Show do
  use QuicWeb, :author_live_view

  alias Quic.Teams
  alias Quic.Accounts

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
      socket
      |> assign(searched_users: %{})
      |> assign(input_text: "")}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:team, Teams.get_team!(id))}
  end


  @impl true
  def handle_event("search_users", %{"text" => input} = _params, socket) do
    users = Accounts.get_author_by_name_or_username(input)
    {:noreply, assign(socket, searched_users: users)}
  end

  @impl true
  def handle_event("clicked_user", %{"username" => username} = _params, socket) do
    Teams.insert_author_in_team(socket.assigns.team, username)
    team = Teams.get_team!(socket.assigns.team.id)
    {:noreply, assign(socket, team: team)}
  end

  defp page_title(:show), do: "Show Team"
  defp page_title(:edit), do: "Edit Team"
end
