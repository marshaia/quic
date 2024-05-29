defmodule QuicWeb.TeamLive.AddCollaboratorForm do
  use QuicWeb, :live_component

  alias Quic.Teams
  alias Quic.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <h4 class="text-[var(--primary-color)]"><%= @title %></h4>
        <:subtitle></:subtitle>
      </.header>

      <form phx-target={@myself} phx-change="validate" class="flex mt-8 rounded-t-xl px-4 py-1 gap-2 bg-[var(--background-view)]">
        <div class="flex items-center justify-center">
          <Heroicons.magnifying_glass class="relative w-5 h-5 text-[var(--primary-color)]" />
        </div>
        <input type="text" id="add_collaborator_input" name="input" class="bg-[var(--background-view)] border-none focus:ring-0 text-sm w-full md:w-80" placeholder="Search by display name or username"/>
      </form>

      <div class="mb-3 h-[233px] rounded-b-xl border-t border-[var(--border)] overflow-auto bg-[var(--background-view)]">
        <%= if Enum.count(@searched_users) === 0 do %>
          <p class="mt-3 text-xs text-center">Nothing to show</p>
        <% else %>
          <div :for={user <- @searched_users} class="hover:bg-[var(--background-card)] cursor-pointer px-4 py-5 w-full border-t border-[var(--border)]" phx-target={@myself} phx-click="clicked_user" phx-value-username={user.username}>
            <p class="font-semibold">
              <%= user.display_name %>
              <span class="ml-2 text-sm font-normal">@<%= user.username %></span>
            </p>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, socket
          |> assign(:input_text, "")
          |> assign(:searched_users, %{})}
  end


  @impl true
  def handle_event("validate", %{"input" => input}, socket) do
    if String.length(input) === 0 do
      {:noreply, assign(socket, searched_users: [], input_text: input)}
    else
      users = Accounts.get_author_by_name_or_username(input)
      result = Enum.reject(users, fn user -> is_user_already_in_team(socket.assigns.team.authors, user.username) end)
      {:noreply, assign(socket, searched_users: result, input_text: input)}
    end
  end

  @impl true
  def handle_event("save", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("clicked_user", %{"username" => username} = _params, socket) do
    Teams.insert_author_in_team(socket.assigns.team, username)
    team = Teams.get_team!(socket.assigns.team.id)
    {:noreply, socket
              |> assign(team: team)
              |> put_flash(:info, "Successfully added #{username} to #{socket.assigns.team.name}!")
              |> push_patch(to: socket.assigns.patch)}
  end


  def is_user_already_in_team(authors, username) do
    Enum.any?(authors, fn member -> member.username === username end)
  end

end
