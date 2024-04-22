defmodule QuicWeb.QuestionAnswerLive.FormComponent do
  use QuicWeb, :live_component

  alias Quic.Questions

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
      <h4 class="text-[var(--primary-color)]"><%= @title %></h4>
        <:subtitle>Use this form to manage question_answer records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="question_answer-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:answer]} type="text" label="Answer" />
        <.input field={@form[:is_correct]} type="checkbox" label="Is correct" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Question answer</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{question_answer: question_answer} = assigns, socket) do
    changeset = Questions.change_question_answer(question_answer)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"question_answer" => question_answer_params}, socket) do
    changeset =
      socket.assigns.question_answer
      |> Questions.change_question_answer(question_answer_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"question_answer" => question_answer_params}, socket) do
    save_question_answer(socket, socket.assigns.action, question_answer_params)
  end

  defp save_question_answer(socket, :edit, question_answer_params) do
    case Questions.update_question_answer(socket.assigns.question_answer, question_answer_params) do
      {:ok, question_answer} ->
        notify_parent({:saved, question_answer})

        {:noreply,
         socket
         |> put_flash(:info, "Question answer updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_question_answer(socket, :new, question_answer_params) do
    case Questions.create_question_answer(question_answer_params) do
      {:ok, question_answer} ->
        notify_parent({:saved, question_answer})

        {:noreply,
         socket
         |> put_flash(:info, "Question answer created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
