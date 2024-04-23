defmodule QuicWeb.TeamLive.AddCollaboratorForm do
  use QuicWeb, :live_component

  alias Quic.Teams
  alias Quic.Accounts

  require Logger

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <h4 class="text-[var(--primary-color)]"><%= @title %></h4>
        <:subtitle></:subtitle>
      </.header>

      <.simple_form
        :let={f}
        for={@form}
        id="add-collaborator-team-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={f[:input]} type="text" label="Search Name or Username" />
        <%!-- <:actions>
          <.button phx-disable-with="Saving..." class="call2actionBtn">Save Team</.button>
        </:actions> --%>
      </.simple_form>

      <%= if String.length(@input_text) > 0 do %>
      <div class="flex flex-col w-full overflow-y-auto max-h-40 border border-[var(--border)] rounded-md mt-3">
        <div :for={user <- @searched_users}>
            <% already_in_team = is_user_already_in_team(@team.authors, user.username) %>
            <.link
              :if={!already_in_team}
              phx-target={@myself}
              class="flex flex-col w-full justify-center p-2 bg-[var(--background-card)]  rounded-md gap-4 active:hover:bg-[--hover] hover:bg-[--hover]"
              phx-click="clicked_user"
              phx-value-username={user.username}
            >
              <p class="font-semibold">
                <%= user.display_name %>
                <span class="ml-2 text-sm font-normal">@<%= user.username %></span>
              </p>
            </.link>
        </div>
      </div>
      <% end %>

    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, socket
          |> assign(:form, %{"input" => ""})
          |> assign(:input_text, "")
          |> assign(:searched_users, %{})}
  end


  @impl true
  def handle_event("validate", %{"input" => input}, socket) do
    users = Accounts.get_author_by_name_or_username(input)
    {:noreply, assign(socket, searched_users: users, input_text: input)}
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
