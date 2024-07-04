defmodule QuicWeb.SessionLive.Leaderboard do
  use QuicWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col items-center w-full h-full">
      <h4 class="mb-8 text-gradient">Leaderboard</h4>

      <div class="bg-[var(--background-card)] p-2 px-6 rounded-xl border border-[var(--border)] overflow-auto max-h-[calc(100vh-20rem)]">
        <.leaderboard participants={@participants} total_questions={@total_questions} />
      </div>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    {:ok, socket |> assign(assigns)}
  end
end
