defmodule QuicWeb.QuestionLive.FormFillBlanks do
  use QuicWeb, :live_component

  alias Quic.Questions
  alias Quic.Questions.QuestionAnswer

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col w-full gap-3">
      <.simple_form
        class="w-full -mt-10"
        :let={f}
        for={@changeset}
        id={"question-answer-form-1" <> (if @responsive, do: "-responsive", else: "")}
        phx-change="validate"
        phx-submit="saveForm"
        phx-target={@myself}
      >
        <.input field={f[:answer]} type="textarea" rows="1" class="flex-1 w-full"/>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{answers: answers, responsive: responsive} = assigns, socket) do
    socket = assign(socket, assigns)

    {:ok, socket
          |> assign(:changeset, Enum.at(answers, 0, Questions.change_question_answer(%QuestionAnswer{})))
          |> assign(:responsive, responsive)}
  end

  @impl true
  def handle_event("validate", %{"question_answer" => params}, socket) do
    answer_params = Map.put(params, "is_correct", true)
    changeset =
      %QuestionAnswer{}
      |> Questions.change_question_answer(answer_params)
      |> Map.put(:action, :validate)

    send(self(), {:question_answers, [changeset]})
    if answer_valid?(changeset), do: send(self(), {:cant_submit, false}), else: send(self(), {:cant_submit, true})

    {:noreply, socket |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("ignore", _params, socket) do
    {:noreply, socket}
  end


  defp answer_valid?(changeset) do
    if Enum.count(changeset.errors) > 0, do: false, else: true
  end
end
