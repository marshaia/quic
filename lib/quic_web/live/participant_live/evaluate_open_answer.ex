defmodule QuicWeb.ParticipantLive.EvaluateOpenAnswerForm do
  use QuicWeb, :author_live_view

  alias QuicWeb.QuicWebAux
  alias Quic.Participants
  alias Quic.ParticipantAnswers

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex justify-start mb-5">
      <.my_back navigate={@back}>Back</.my_back>
    </div>

    <section class="p-4 mt-5 rounded-md bg-[var(--background-card)] border border-[var(--border)]">
      <div class="flex items-center justify-between">
        <div class={["rounded-md px-2", QuicWebAux.get_type_color(@question.type)]}>
          <span class="text-xs text-white"><%= QuicWebAux.readable_name(@question.type) %></span>
        </div>
        <div class="flex gap-1">
          <Heroicons.trophy class="w-5 h-5" />
          <p><%= @question.points %> Points</p>
        </div>
      </div>
      <p id="question-page-prism-hook" phx-hook="PrismInitializer" class="mt-4 overflow-auto text-justify"><.markdown text={@question.description} /></p>
      <hr class="w-full my-5" />

      <% participant_answer = Enum.find(@participant.answers, fn a -> a.question_id === @question.id end) %>
      <%= if participant_answer === nil do %>
        <p>Participant hasn't responded to this question yet.</p>
      <% else %>
        <p class="font-medium text-[var(--primary-color)]">Response:</p>
        <.markdown class="w-full" text={Enum.at(participant_answer.answer, 0, "")} />
      <% end %>
    </section>

    <.simple_form
      for={@changeset}
      :let={f}
      id="evaluate-open-answer-form"
      phx-change="validate"
      phx-submit="save"
    >
      <div class="-mb-5">
        <.input field={f[:points_obtained]} type="number" label="Points" />
      </div>
      <%= if @error_msg !== nil do %>
        <.error><%= @error_msg %></.error>
      <% end %>

      <:actions>
        <.button phx-disable-with="Saving..." class="call2actionBtn" disabled={@error_msg !== nil}><p class="font-normal text-white">Assign</p></.button>
      </:actions>
    </.simple_form>
    """
  end

  @impl true
  def mount(%{"session_id" => session_id, "participant_id" => participant_id, "question_position" => question_position}, _session, socket) do
    {question_position, _} = Integer.parse(question_position)
    if participant = Participants.participant_belongs_to_session?(participant_id, session_id) do
      case Enum.find(participant.session.quiz.questions, fn q -> q.position === question_position end) do
        nil -> {:ok, socket |> put_flash(:error, "Invalid Question") |> redirect(to: ~p"/session/#{session_id}/participants/#{participant_id}")}
        question ->
          participant_answer = Enum.find(participant.answers, fn a -> a.question_id === question.id end)
          if participant_answer === nil do
            {:ok, socket |> put_flash(:error, "Participant has not submitted an answer yet!") |> redirect(to: ~p"/session/#{session_id}/participants/#{participant_id}")}
          else
            if Participants.participant_answer_has_been_assessed?(participant, question.id) do
              {:ok, socket |> put_flash(:error, "Question has already been assessed") |> redirect(to: ~p"/session/#{session_id}/participants/#{participant_id}")}

            else
              {:ok, socket
                |> assign(:error_msg, nil)
                |> assign(:question, question)
                |> assign(:participant, participant)
                |> assign(:participant_answer, participant_answer)
                |> assign(:page_title, "Session - Show Participant")
                |> assign(:back, "/session/#{session_id}/participants/#{participant_id}")
                |> assign(:changeset, ParticipantAnswers.change_participant_answer(participant_answer))
                |> assign(:current_path, "/session/#{session_id}/participants/#{participant_id}/evaluate-open-answer/#{question_position}")}
          end
        end
      end
    end
  end

  @impl true
  def handle_event("validate", %{"participant_answer" => %{"points_obtained" => points}}, socket) do
    case Integer.parse(points) do
      :error -> {:noreply, socket |> assign(:error_msg, "You can only assign between 0 and #{socket.assigns.question.points} points")}
      {points, _} ->
        if points < 0 || points > socket.assigns.question.points do
          {:noreply, socket |> assign(:error_msg, "You can only assign between 0 and #{socket.assigns.question.points} points")}
        else
          {:noreply, socket |> assign(changeset: ParticipantAnswers.change_participant_answer(socket.assigns.participant_answer, %{"points_obtained" => points}), error_msg: nil)}
        end
    end
  end

  @impl true
  def handle_event("save", %{"participant_answer" => points}, socket) do
    {integer_points, _} = Integer.parse(points["points_obtained"])
    attrs = if integer_points > 0, do: Map.put(points, "result", :correct), else: Map.put(points, "result", :incorrect)

    case ParticipantAnswers.update_participant_answer(socket.assigns.participant_answer, attrs) do
      {:ok, _} ->
        participant = socket.assigns.participant
        case Participants.update_participant(participant, %{"total_points" => participant.total_points + integer_points}) do
          {:ok, _} -> {:noreply, socket |> put_flash(:info, "Points assigned successully!") |> redirect(to: socket.assigns.back)}
          {:error, _} -> {:noreply, socket |> put_flash(:error, "Error updating Participant's total points. Please try again!")}
        end
      {:error, _} -> {:noreply, socket |> put_flash(:error, "Error updating points. Please try again!")}
    end
  end

end
