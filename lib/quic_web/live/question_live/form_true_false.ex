defmodule QuicWeb.QuestionLive.FormTrueFalse do
  use QuicWeb, :live_component

  alias Quic.Questions
  alias Quic.Questions.QuestionAnswer

  require Logger

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        :let={f}
        for={@changeset}
        id="question-true-false-answer-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="ignore"
      >
        <.input
          field={f[:is_correct]}
          type="select"
          label="True or False"
          options={["True": true, "False": false]}
        />
      </.simple_form>
    </div>
    """
  end


  # @impl true
  # def mount(socket) do

  # end

  @impl true
  def update(%{answers: answers} = assigns, socket) do
    socket = assign(socket, assigns)

    {:ok, socket |> assign(:changeset, Enum.at(answers, 0, Questions.change_question_answer(%QuestionAnswer{})))}
  end


  @impl true
  def handle_event("validate", %{"question_answer" => params}, socket) do
    answer_params = Map.put(params, "answer", ".")
    changeset =
      %QuestionAnswer{}
      |> Questions.change_question_answer(answer_params)
      |> Map.put(:action, :validate)

    send(self(), {:question_answers, [changeset]})
    send(self(), {:cant_submit, false})

    {:noreply, socket |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("ignore", _params, socket) do
    {:noreply, socket}
  end

end
