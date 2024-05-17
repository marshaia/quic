defmodule QuicWeb.QuestionLive.FormSingleMultipleChoice do
  use QuicWeb, :live_component

  alias Quic.Questions
  alias Quic.Questions.QuestionAnswer

  require Logger

  # After the component is updated, render/1 is called with all assigns. On first render, we get:
  # mount(socket) -> update(assigns, socket) -> render(assigns)
  # On further rendering:
  # update(assigns, socket) -> render(assigns)

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col w-full gap-3 mt-10">
      <.simple_form
        class="w-full -mt-10"
        :let={f}
        for={@changeset_1}
        id="question-answer-form-1"
        phx-change="validateAnswer"
        phx-submit="saveForm"
        phx-value-id="1"
        phx-target={@myself}
      >
        <div class="flex items-center w-full gap-4">
          <.input field={f[:is_correct]} type="checkbox"/>
          <div class="flex-1">
           <.input field={f[:answer]} type="textarea" rows="1" class="flex-1 w-full"/>
          </div>
        </div>
      </.simple_form>

      <.simple_form
        class="w-full -mt-10"
        :let={f}
        for={@changeset_2}
        id="question-answer-form-2"
        phx-change="validateAnswer"
        phx-submit="saveForm"
        phx-value-id="2"
        phx-target={@myself}
      >
        <div class="flex items-center w-full gap-4">
          <.input field={f[:is_correct]} type="checkbox"/>
          <div class="flex-1">
           <.input field={f[:answer]} type="textarea" rows="1" class="flex-1 w-full"/>
          </div>
        </div>
      </.simple_form>

      <.simple_form
        class="w-full -mt-10"
        :let={f}
        for={@changeset_3}
        id="question-answer-form-3"
        phx-change="validateAnswer"
        phx-submit="saveForm"
        phx-value-id="3"
        phx-target={@myself}
      >
        <div class="flex items-center w-full gap-4">
          <.input field={f[:is_correct]} type="checkbox"/>
          <div class="flex-1">
           <.input field={f[:answer]} type="textarea" rows="1" class="flex-1 w-full"/>
          </div>
        </div>
      </.simple_form>

      <.simple_form
        class="w-full -mt-10"
        :let={f}
        for={@changeset_4}
        id="question-answer-form-4"
        phx-change="validateAnswer"
        phx-value-id="4"
        phx-submit="saveForm"
        phx-target={@myself}
      >
        <div class="flex items-center w-full gap-4">
          <.input field={f[:is_correct]} type="checkbox"/>
          <div class="flex-1">
           <.input field={f[:answer]} type="textarea" rows="1" class="flex-1 w-full"/>
          </div>
        </div>
      </.simple_form>
    </div>
    """
  end

  # is called once, when the component is first added to the page.
  # @impl true
  # def mount(socket) do
  #   {:ok, socket}
  # end

  # is invoked with all of the assigns given to
  # If is not defined all assigns are simply merged into the socket.
  @impl true
  def update(%{type: type, answers: answers} = assigns, socket) do
    socket = socket |> assign(assigns) |> assign(type: type)

    {:ok, socket
          |> assign(:changeset_1, Enum.at(answers, 0, Questions.change_question_answer(%QuestionAnswer{})))
          |> assign(:changeset_2, Enum.at(answers, 1, Questions.change_question_answer(%QuestionAnswer{})))
          |> assign(:changeset_3, Enum.at(answers, 2, Questions.change_question_answer(%QuestionAnswer{})))
          |> assign(:changeset_4, Enum.at(answers, 3, Questions.change_question_answer(%QuestionAnswer{})))}
  end


  @impl true
  def handle_event("validateAnswer", %{"question_answer" => answer_params, "id" => id}, socket) do
    changeset =
      %QuestionAnswer{}
      |> Questions.change_question_answer(answer_params)
      |> Map.put(:action, :validate)

    socket = assign(socket, String.to_atom("changeset_" <> id), changeset)
    changesets = [socket.assigns.changeset_1, socket.assigns.changeset_2, socket.assigns.changeset_3, socket.assigns.changeset_4]
    send(self(), {:question_answers, changesets})

    if socket.assigns.type === :single_choice do
      if only_one_correct_option?(changesets) do
        send(self(), :no_error_answers)
        if all_answers_valid?(changesets), do: send(self(), {:cant_submit, false}), else: send(self(), {:cant_submit, true})
        {:noreply, socket}
      else
        send(self(), {:error_answers, "Question has to have only 1 correct option!"})
        send(self(), {:cant_submit, true})
        {:noreply, socket}
      end

    else
      if more_than_one_correct_option?(changesets) do
        send(self(), :no_error_answers)
        if all_answers_valid?(changesets), do: send(self(), {:cant_submit, false}), else: send(self(), {:cant_submit, true})
        {:noreply, socket}
      else
        send(self(), {:error_answers, "Question has to have more than 1 correct option!"})
        send(self(), {:cant_submit, true})
        {:noreply, socket}
      end
    end

  end

  defp only_one_correct_option?(changesets) do
    res = Enum.reduce(changesets, 0,
      fn changeset, acc ->
        if (Map.has_key?(changeset.changes, :is_correct) && changeset.changes.is_correct) || (Map.has_key?(changeset.data, :is_correct) && changeset.data.is_correct) do
          acc + 1
        else
          acc
        end
      end)

    res === 1
  end

  defp more_than_one_correct_option?(changesets) do
    res = Enum.reduce(changesets, 0,
      fn changeset, acc ->
        if (Map.has_key?(changeset.changes, :is_correct) && changeset.changes.is_correct) || (Map.has_key?(changeset.data, :is_correct) && changeset.data.is_correct) do
          acc + 1
        else
          acc
        end
      end)

    res > 1
  end

  defp all_answers_valid?(changesets) do
    Enum.reduce(changesets, true, fn changeset, acc -> if Enum.count(changeset.errors) > 0, do: false, else: acc end)
  end


end
