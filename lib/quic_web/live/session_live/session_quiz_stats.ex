defmodule QuicWeb.SessionLive.SessionQuizStats do
  use QuicWeb, :live_component


  @impl true
  def render(assigns) do
    ~H"""
    <div class="h-20">
      <canvas
        id="my-chart"
        phx-hook="ChartJS"
        data-points={Jason.encode!(@points)}
        data-labels={Jason.encode!(@labels)}

      ></canvas>

      <%!-- <.button phx-target={@myself} phx-click="change-data" class="call2actionBtn">change</.button> --%>
    </div>
    """
  end


  @impl true
  def update(_assigns, socket) do
    {:ok, socket
          |> assign(:points, [10, 5])
          |> assign(:labels, ["correct", "incorrect"])}
  end

  @impl true
  def handle_event("change-data", _params, socket) do
    {:noreply, socket |> push_event("update-points", %{points: [20, 10]})}
  end


end
