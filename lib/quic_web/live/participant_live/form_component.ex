defmodule QuicWeb.ParticipantLive.FormComponent do
  use QuicWeb, :live_component

  alias Quic.Participants

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage participant records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="participant-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:total_points]} type="number" label="Total points" />
        <.input field={@form[:current_question]} type="number" label="Current question" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Participant</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{participant: participant} = assigns, socket) do
    changeset = Participants.change_participant(participant)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"participant" => participant_params}, socket) do
    changeset =
      socket.assigns.participant
      |> Participants.change_participant(participant_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"participant" => participant_params}, socket) do
    save_participant(socket, socket.assigns.action, participant_params)
  end

  defp save_participant(socket, :edit, participant_params) do
    case Participants.update_participant(socket.assigns.participant, participant_params) do
      {:ok, participant} ->
        notify_parent({:saved, participant})

        {:noreply,
         socket
         |> put_flash(:info, "Participant updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_participant(socket, :new, participant_params) do
    case Participants.create_participant(participant_params) do
      {:ok, participant} ->
        notify_parent({:saved, participant})

        {:noreply,
         socket
         |> put_flash(:info, "Participant created successfully")
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
