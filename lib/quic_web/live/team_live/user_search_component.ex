defmodule QuicWeb.TeamLive.UserSearchComponent do
  use QuicWeb, :live_component


  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        id="team-user-search-form"
        phx-target={@myself}
        phx-change="search"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <%!-- <:actions>
          <.button phx-disable-with="Saving..." class="call2actionBtn">Save Team</.button>
        </:actions> --%>
      </.simple_form>

      <p :for={user <- @users}><%= user %></p>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{"input" => %{"name" => ""}}))}
  end

  def handle_event("search", %{"input" => %{"name" => input}}, socket) do
    # search for user in data base
    #users = %{ "name" => "joana alves"}

    # send result in event to parent
    socket = assign(socket, :searched_users, "joana alves")
    {:noreply, assign(socket, form: to_form(%{"input" => %{"name" => input}}))}
  end


  def handle_event("save", _params, socket) do
    # search for user in data base
    users = %{ "name" => "joana alves"}

    # send result in event to parent
    socket = assign(socket, :searched_users, users)
    {:noreply, assign(socket, form: to_form(%{"input" => %{"name" => "joana alves"}}))}
  end

end
