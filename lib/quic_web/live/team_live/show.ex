defmodule QuicWeb.TeamLive.Show do
  use QuicWeb, :author_live_view

  alias Quic.Teams
  alias Quic.Quizzes
  alias QuicWeb.QuicWebAux

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(searched_users: %{}) |> assign(input_text: "") |> assign(color: 1)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    if Teams.is_author_allowed_in_team(id, socket.assigns.current_author.id) do
      {:noreply, socket
        |> assign(:page_title, page_title(socket.assigns.live_action))
        |> assign(:team, Teams.get_team!(id))
        |> assign(:current_path, "/teams/#{id}")}
    else
      {:noreply, socket |> put_flash(:error, "You can't access Teams you're not a member of!") |> redirect(to: ~p"/teams")}
    end
  end


  @impl true
  def handle_event("delete_team", %{"id" => id}, socket) do
    team = Teams.get_team!(id)
    case Teams.delete_team(team) do
      {:ok, _} -> {:noreply, socket |> put_flash(:info, "Team deleted successfully!") |> redirect(to: ~p"/teams")}
      {:error, _} -> {:noreply, socket |> put_flash(:info, "Something went wrong!")}
    end
  end

  @impl true
  def handle_event("remove_author", %{"team" => team_id, "author" => author_id}, socket) do
    are_removing_themselves = author_id === socket.assigns.current_author.id
    case Teams.remove_author_from_team(team_id, author_id) do
      {:ok, _} ->
        Teams.check_empty_team(team_id)
        if are_removing_themselves do
          {:noreply, socket |> put_flash(:info, "Successfully removed from team!") |> redirect(to: ~p"/teams")}
        else
          {:noreply, socket |> assign(:team, Teams.get_team!(team_id)) |> put_flash(:info, "Collaborator successfully removed from team!")}
        end

      _ -> {:noreply, socket |> put_flash(:error, "Something went wrong! :(")}
    end
  end

  # REMOVE QUIZ
  @impl true
  def handle_event("delete_quiz", %{"id" => quiz_id}, socket) do
    case Teams.remove_quiz_from_team(socket.assigns.team.id, quiz_id) do
      {1, nil} ->
        {:noreply, socket
          |> assign(:team, Teams.get_team!(socket.assigns.team.id))
          |> put_flash(:info, "Quiz successfully removed from team!")}

      {_, _} ->
        {:noreply, socket |> put_flash(:info, "Something went wrong! :(")}
    end
  end

  @impl true
  def handle_event("clicked_quiz", %{"id" => quiz_id}, socket) do
    {:noreply, socket |> redirect(to: ~p"/quizzes/#{quiz_id}")}
  end

  @impl true
  def handle_event("clicked_user", %{"id" => author_id}, socket) do
    {:noreply, socket |> redirect(to: ~p"/authors/profile/#{author_id}")}
  end


  defp page_title(:show), do: "Show Team"
  defp page_title(:edit), do: "Edit Team"
  defp page_title(:add_quiz), do: "Add Quiz"
  defp page_title(:add_collaborator), do: "Add Collaborator"
end
