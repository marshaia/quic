defmodule QuicWeb.QuizLive.FormComponent do
  use QuicWeb, :live_component

  alias Quic.Quizzes

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <h5 class="text-[var(--primary-color)]"><%= @title %></h5>
      </.header>

      <.simple_form
        for={@form}
        id="quiz-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="textarea" label="Description" />
        <.input field={@form[:public]} type="checkbox" label="Public?" />
        <:actions>
          <.button phx-disable-with="Saving..." class="call2actionBtn"><p class="font-normal text-white">Save Quiz</p></.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{quiz: quiz} = assigns, socket) do
    changeset = Quizzes.change_quiz(quiz)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"quiz" => quiz_params}, socket) do
    changeset =
      socket.assigns.quiz
      |> Quizzes.change_quiz(quiz_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"quiz" => quiz_params}, socket) do
    quiz_params = Map.put(quiz_params, "author_id", socket.assigns.current_author.id)
    save_quiz(socket, socket.assigns.action, quiz_params)
  end

  defp save_quiz(socket, :edit, quiz_params) do
    case Quizzes.update_quiz(socket.assigns.quiz, quiz_params) do
      {:ok, quiz} ->
        notify_parent({:saved, quiz})

        {:noreply,
         socket
         |> put_flash(:info, "Quiz updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_quiz(socket, :new, quiz_params) do
    quiz_params = Map.put(quiz_params, "total_points", 0)
    case Quizzes.create_quiz_with_author(quiz_params, socket.assigns.current_author.id) do
      {:ok, quiz} ->
        notify_parent({:saved, quiz})

        {:noreply,
         socket
         |> put_flash(:info, "Quiz created successfully")
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
