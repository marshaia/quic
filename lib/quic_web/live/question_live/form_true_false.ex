defmodule QuicWeb.QuestionLive.FormTrueFalse do
  use QuicWeb, :live_component

  alias Quic.Questions
  alias Quic.Questions.QuestionAnswer

  require Logger

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full -mt-2">
      <.simple_form
        :let={f}
        for={@changeset}
        id={"question-true-false-answer-form" <> (if @responsive, do: "-responsive", else: "")}
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
  def update(%{answers: answers, responsive: responsive} = assigns, socket) do
    socket = assign(socket, assigns)

    {:ok, socket
          |> assign(:changeset, Enum.at(answers, 0, Questions.change_question_answer(%QuestionAnswer{})))
          |> assign(:responsive, responsive)}
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
