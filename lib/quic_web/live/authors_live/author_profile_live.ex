defmodule QuicWeb.AuthorProfile do
  use QuicWeb, :author_live_view

  alias Quic.Teams
  alias Quic.Quizzes
  alias Quic.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <div class="bg-[var(--background-card)] gap-1 py-4 p-2 rounded-md flex flex-col justify-center items-center border border-[var(--border)]">
      <h4 class="text-gradient"><%= @author.display_name %></h4>
      <p>@<%= @author.username %></p>
      <%!-- <p><%= @author.email %></p> --%>

      <div class="flex justify-between w-[85%] md:w-[50%] mt-5">
        <div class="flex items-center gap-2">
          <Heroicons.pencil_square class="w-5 h-5 stroke-1"/>
          <p class="text-gray-500 dark:text-gray-400"><%= Enum.count(@quizzes)%> Quizzes</p>
        </div>
        <div class="flex items-center gap-2">
          <Heroicons.user_group class="w-5 h-5 stroke-1"/>
          <p class="text-gray-500 dark:text-gray-400"><%= Enum.count(@teams)%> Teams</p>
        </div>
      </div>
    </div>

    <%!-- PUBLIC QUIZZES --%>
    <h6 class="mt-8 text-xl">Public Quizzes</h6>
    <div class="grid w-full grid-cols-1 gap-2 mt-2 overflow-auto lg:grid-cols-2" style="grid-auto-rows: 1fr">
      <div :for={{quiz, index} <- Enum.with_index(@quizzes)}>
        <.quiz_box
          index={index + 1}
          quiz={quiz}
          isOwner={Quizzes.is_owner?(quiz.id, @author)}
          current_author_id={@author.id}
        />
      </div>
    </div>
    """
  end


  @impl true
  def mount(%{"id" => author_id}, _session, socket) do
    author = Accounts.get_author!(author_id)
    {:ok, socket
          |> assign(:author, author)
          |> assign(:quizzes, Quizzes.list_all_author_public_quizzes(author_id))
          |> assign(:teams, Teams.list_all_author_teams(author_id))
          |> assign(:page_title, "#{author.display_name}'s Profile")
          |> assign(:current_path, "/authors/profile")}
  end

  @impl true
  def mount(_params, _session, socket) do
    author_id = socket.assigns.current_author.id
    {:ok, socket
        |> assign(:author, socket.assigns.current_author)
        |> assign(:quizzes, Quizzes.list_all_author_public_quizzes(author_id))
        |> assign(:teams, Teams.list_all_author_teams(author_id))
        |> assign(:page_title, "Author Profile")
        |> assign(:current_path, "/authors/profile")}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("clicked_quiz", %{"id" => id}, socket) do
    {:noreply, redirect(socket, to: "/quizzes/#{id}")}
  end
end
