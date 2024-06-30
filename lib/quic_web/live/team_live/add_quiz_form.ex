defmodule QuicWeb.TeamLive.AddQuizForm do
  use QuicWeb, :live_component

  alias Quic.Teams
  alias Quic.Quizzes

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <h5 class="text-[var(--primary-color)]"><%= @title %></h5>
      </.header>

      <form phx-target={@myself} phx-change="validate" class="flex mt-8 rounded-t-xl px-4 py-1 gap-2 bg-[var(--background-view)] border-x border-t border-[var(--border)]">
        <div class="flex items-center justify-center">
          <Heroicons.magnifying_glass class="relative w-5 h-5 text-[var(--primary-color)]" />
        </div>
        <input type="text" id="add_quiz_input" name="input" class="bg-[var(--background-view)] border-none focus:ring-0 text-sm w-full md:w-80" placeholder="name or description"/>
      </form>

      <div class="mb-3 h-[233px] rounded-b-xl border border-[var(--border)] overflow-auto bg-[var(--background-view)]">
        <%= if Enum.count(@searched_quizzes) === 0 do %>
          <p class="mt-3 text-xs text-center">Nothing to show</p>
        <% else %>
          <div :for={quiz <- @searched_quizzes} class="hover:bg-[var(--background-card)] cursor-pointer px-4 py-5 w-full border-t border-[var(--border)]" phx-target={@myself} phx-click="clicked_quiz" phx-value-id={quiz.id}>
            <p class="-mt-1 font-medium text-[var(--primary-color-text)]"><%= if String.length(quiz.name) > 25, do: String.slice(quiz.name, 0..25) <> "...", else: quiz.name %></p>
            <p class="text-xs"><%= if String.length(quiz.description) > 50, do: String.slice(quiz.description, 0..50) <> "...", else: quiz.description %></p>
            <div class="flex justify-between gap-2 mt-4">
              <div class="flex gap-1">
                <Heroicons.list_bullet class="w-5 h-5 stroke-1" />
                <p class="text-gray-500 dark:text-gray-400"><%= Enum.count(quiz.questions) %> Questions</p>
              </div>
              <div class="flex gap-1">
                <Heroicons.user class="w-5 h-5 stroke-1"/>
                <p class="text-gray-500 dark:text-gray-400"><%= quiz.author.display_name %></p>
              </div>
            </div>
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
          |> assign(:searched_quizzes, %{})}
  end


  @impl true
  def handle_event("validate", %{"input" => input}, socket) do
    if String.length(input) === 0 do
      {:noreply, assign(socket, searched_quizzes: [], input_text: input)}
    else
      quizzes = Quizzes.filter_author_quizzes(socket.assigns.current_author.id, input)
      result = Enum.reject(quizzes, fn quiz -> is_quiz_already_in_team(socket.assigns.team.quizzes, quiz.id) end)
      {:noreply, assign(socket, searched_quizzes: result, input_text: input)}
    end
  end

  @impl true
  def handle_event("save", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("clicked_quiz", %{"id" => quiz_id} = _params, socket) do
    Teams.insert_quiz_in_team(socket.assigns.team, quiz_id)
    team = Teams.get_team!(socket.assigns.team.id)
    {:noreply, socket
              |> assign(team: team)
              |> put_flash(:info, "Successfully added Quiz to #{socket.assigns.team.name}!")
              |> push_patch(to: socket.assigns.patch)}
  end


  def is_quiz_already_in_team(quizzes, quiz_id) do
    Enum.any?(quizzes, fn member -> member.id === quiz_id end)
  end
end
