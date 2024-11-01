defmodule QuicWeb.AuthorProfile do
  use QuicWeb, :author_live_view

  alias Quic.Teams
  alias Quic.Quizzes
  alias Quic.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <div class="bg-[var(--background-card)] gap-1 py-6 p-2 rounded-md flex flex-col justify-center items-center border border-[var(--border)]">
      <h4 class="text-gradient"><%= @author.display_name %></h4>
      <p>@<%= @author.username %></p>
    </div>

    <%!-- PUBLIC QUIZZES --%>
    <h6 class="mt-8 text-xl">Public Quizzes <span class="text-sm font-normal">(<%= Enum.count(@quizzes) %>)</span></h6>
    <div class="grid w-full grid-cols-1 gap-2 mt-2 overflow-auto lg:grid-cols-2" style="grid-auto-rows: 1fr">
      <%= if Enum.count(@quizzes) === 0 do %>
        <p>Nothing to show</p>
      <% else %>
        <div :for={{quiz, index} <- Enum.with_index(@quizzes)}>
          <.quiz_box
            index={index + 1}
            quiz={quiz}
            isOwner={Quizzes.is_owner?(quiz.id, @current_author)}
            current_author_id={@current_author.id}
          />
        </div>
      <% end %>
    </div>
    """
  end


  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end


  @impl true
  def handle_params(%{"id" => author_id}, _uri, socket) do
    my_profile? = author_id === socket.assigns.current_author.id
    author = if my_profile?, do: socket.assigns.current_author, else: Accounts.get_author(author_id)
    case author do
      nil -> {:noreply, socket |> put_flash(:error, "Invalid User") |> redirect(to: ~p"/")}
      author ->
        {:noreply, socket
          |> assign(:author, author)
          |> assign(:quizzes, Quizzes.list_all_author_public_quizzes(author_id))
          |> assign(:teams, Teams.list_all_author_teams(author_id))
          |> assign(:page_title, (if my_profile?, do: "Your Profile", else: "#{author.display_name}"))
          |> assign(:current_path, "/authors/profile/#{author.id}")}
    end
  end

  @impl true
  def handle_event("clicked_quiz", %{"id" => id}, socket) do
    {:noreply, redirect(socket, to: "/quizzes/#{id}")}
  end
end
