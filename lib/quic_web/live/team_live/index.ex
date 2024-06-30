defmodule QuicWeb.TeamLive.Index do
  use QuicWeb, :author_live_view

  alias Quic.Teams
  alias Quic.Teams.Team

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :teams, Teams.list_all_author_teams(socket.assigns.current_author.id))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, socket |> assign(:current_path, "/teams/") |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Team")
    |> assign(:team, %Team{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Teams")
    |> assign(:team, nil)
    |> assign(:current_path, "/teams")
  end

  @impl true
  def handle_info({QuicWeb.TeamLive.FormComponent, {:saved, _}}, socket) do
    {:noreply, assign(socket, :teams, Teams.list_all_author_teams(socket.assigns.current_author.id))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    team = Teams.get_team!(id)
    {:ok, _} = Teams.delete_team(team)

    {:noreply, assign(socket, :teams, Teams.list_all_author_teams(socket.assigns.current_author.id))}
  end

  @impl true
  def handle_event("clicked_team", %{"id" => id}, socket) do
    {:noreply, redirect(socket, to: "/teams/#{id}")}
  end

  @impl true
  def handle_event("form_team_changed", %{"team_input" => input}, socket) do
    {:noreply, socket |> assign(:teams, filter_author_teams(socket.assigns.current_author.id, input))}
  end

  defp filter_author_teams(author_id, input) do
    if String.length(input) === 0 do
      Teams.list_all_author_teams(author_id)
    else
      Enum.reduce(Teams.list_all_author_teams(author_id), [],
        fn team, acc ->
          if String.match?(team.name, ~r/\w*#{input}\w*/i) || String.match?(team.description, ~r/\w*#{input}\w*/i), do: [team | acc], else: acc
        end)
    end
  end
end
