defmodule QuicWeb.ParticipantLive.EnterSessionForm do
  use QuicWeb, :live_view

  alias Quic.Participants
  alias Quic.Participants.Participant


  @impl true
  def render(assigns) do
    ~H"""
    <div id="participant-enter-session-section" phx-hook="SessionChannelParticipant" class="max-w-md px-4 py-4 mx-auto mt-10">
      <div class="flex items-center justify-center gap-2">
        <Heroicons.bolt class="text-[var(--primary-color)] w-11 h-11 stroke-1"/>
        <h4 class="font-medium">Join a Live Session</h4>
      </div>

      <.simple_form
        :let={f}
        for={@changeset}
        id="session-enter-form"
        phx-change="validate"
        phx-submit="save"
        class="w-full"
        actionClass="justify-center"
      >

        <.input field={f[:code]} id="join-session-input-code" type="text" maxlength="5" minlength="5" style="text-transform: uppercase;" placeholder="CODE" label="Session Code" required/>
        <.input field={f[:name]} id="join-session-input-username" type="text" placeholder="a12345" minlength="1" label="Your Name" required/>
        <%= if String.length(@error_name) > 0 do %>
          <.error> <%= @error_name %> </.error>
        <% end %>

        <:actions>
          <.button class="call2actionBtn" id="join-session-button" phx-disable-with="Joining..." disabled={String.length(@error_name) > 0}><p class="font-normal text-white">Join Session</p></.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket
          |> assign(:page_title, "Join Session")
          |> assign(:participant, %{})
          |> assign(:code, "")
          |> assign(:changeset,  %{"code" => "", "name" => ""})
          |> assign(:error_name, "")}
  end

  @impl true
  def handle_event("validate", %{"code" => code, "name" => name}, socket) do
    socket = assign(socket, :error_name, "")
    code = String.upcase(code)
    changeset = %Participant{} |> Participants.change_participant_validate(%{"name" => name}, code)

    if Enum.count(changeset.errors) > 0 do
      [name: {msg, _}] = changeset.errors
      {:noreply, socket |> assign(error_name: msg, changeset: %{"code" => code, "name" => name})}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("save", %{"code" => code, "name" => username}, socket) do
    code = String.upcase(code)
    socket = push_event(socket, "join_session", %{"username" => username, "code" => code})
    {:noreply, assign(socket, :code, code)}
  end

  @impl true
  def handle_event("joined_session", %{"participant" => participant_id}, socket) do
    {:noreply, socket
      |> assign(:participant, Participants.get_participant!(participant_id))
      |> redirect(to: ~p"/live-session/#{socket.assigns.code}/#{participant_id}")}
  end

  def handle_event("error_joining_session", %{"reason" => msg}, socket) do
    {:noreply, socket |> put_flash(:error, msg)}
  end

  @impl true
  def handle_info(_, socket), do: {:noreply, socket}

end
