defmodule QuicWeb.QuestionLive.FormComponent do
  use QuicWeb, :live_component

  alias Quic.Questions

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <h4 class="text-[var(--primary-color)]"><%= @title %></h4>
        <:subtitle></:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="question-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <%!-- <.input field={@form[:title]} type="text" label="Title" /> --%>
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:points]} type="number" label="Points" />
        <.input
          field={@form[:type]}
          type="select"
          label="Type"
          prompt="Choose a value"
          options={["Multiple Choice": :multiple_choice, "True or False": :true_false, "Fill in the Blanks": :fill_the_blanks, "Open Answer": :open_answer]}
        />
        <:actions>
          <.button class="call2actionBtn" phx-disable-with="Saving...">Save Question</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{question: question} = assigns, socket) do
    changeset = Questions.change_question(question)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"question" => question_params}, socket) do
    changeset =
      socket.assigns.question
      |> Questions.change_question(question_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"question" => question_params}, socket) do
    socket = assign(socket, quiz_id: socket.assigns.quiz_id)
    save_question(socket, socket.assigns.action, question_params)
  end

  defp save_question(socket, :edit, question_params) do
    case Questions.update_question(socket.assigns.question, question_params) do
      {:ok, question} ->
        notify_parent({:saved, question})

        {:noreply,
         socket
         |> put_flash(:info, "Question updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_question(socket, :new, question_params) do
    case Questions.create_question(question_params) do
      {:ok, question} ->
        notify_parent({:saved, question})

        {:noreply,
         socket
         |> put_flash(:info, "Question created successfully")
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
