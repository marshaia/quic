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
    {:noreply, assign(socket, searched_users: users, input_text: input)}
  end

  @impl true
  def handle_event("clicked_user", %{"username" => username} = _params, socket) do
    Teams.insert_author_in_team(socket.assigns.team, username)
    team = Teams.get_team!(socket.assigns.team.id)
    {:noreply, socket
              |> assign(team: team)
              |> put_flash(:info, "Successfully added #{username} to #{socket.assigns.team.name}!")}
  end

  def is_user_already_in_team(authors, username) do
    Enum.any?(authors, fn member -> member.username === username end)
  end

  defp page_title(:show), do: "Show Team"
  defp page_title(:edit), do: "Edit Team"
end
