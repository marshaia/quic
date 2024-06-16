defmodule QuicWeb.QuizLive.NewQuestionForm do
  use QuicWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <h5 class="text-[var(--primary-color)]">New Question</h5>
        <:subtitle>
          <p>Please choose the question's type</p>
        </:subtitle>
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="quiz-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >

        <.input
          field={f[:type]}
          type="select"
          label="Type"
          prompt="Choose a value"
          options={["Single Choice": :single_choice, "Multiple Choice": :multiple_choice, "True or False": :true_false, "Fill in the Blank": :fill_the_blanks, "Fill the Code": :fill_the_code, "Open Answer": :open_answer, "Code": :code]}
        />

        <:actions>
          <.button disabled={@selected === nil} phx-disable-with="Saving..." class="call2actionBtn"><p class="font-normal text-white">Create Question</p></.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end


  @impl true
  def mount(socket) do
    {:ok, socket |> assign(:selected, nil)}
  end

  @impl true
  def update(%{id: quiz_id} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:quiz_id, quiz_id)
     |> assign(:changeset, %{})}
  end

  @impl true
  def handle_event("validate", %{"type" => type} = params, socket) do
    # changeset =
    #   socket.assigns.quiz
    #   |> Quizzes.change_quiz(quiz_params)
    #   |> Map.put(:action, :validate)

    # {:noreply, assign_form(socket, changeset)}
    {:noreply, socket |> assign(:selected, type) |> assign(:changeset, params)}
  end

  def handle_event("save", %{"type" => type}, socket) do
    {:noreply, socket |> redirect(to: ~p"/quizzes/#{socket.assigns.quiz_id}/new-question/#{type}")}
  end

  # defp save_quiz(socket, :new, quiz_params) do
  #   quiz_params = Map.put(quiz_params, "total_points", 0)
  #   case Quizzes.create_quiz_with_author(quiz_params, socket.assigns.current_author.id) do
  #     {:ok, quiz} ->
  #       notify_parent({:saved, quiz})

  #       {:noreply,
  #        socket
  #        |> put_flash(:info, "Quiz created successfully")
  #        |> push_patch(to: socket.assigns.patch)}

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       {:noreply, assign_form(socket, changeset)}
  #   end
  # end

  # defp assign_form(socket, %Ecto.Changeset{} = changeset) do
  #   assign(socket, :form, to_form(changeset))
  # end

  #defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
