defmodule QuicWeb.ParticipantLive.EnterSessionForm do
  use QuicWeb, :live_view

  alias Quic.Participants
  alias Quic.Participants.Participant

  def mount(_params, _session, socket) do
    {:ok, socket
          |> assign(:page_title, "Join Session")
          |> assign(:participant, %{})
          |> assign(:code, "")
          |> assign(:changeset,  %{"code" => "", "name" => ""})
          |> assign(:error_name, "")}
  end

  def handle_event("validate", %{"code" => code, "name" => name}, socket) do
    socket = assign(socket, :error_name, "")

    if String.length(code) === 5, do: Phoenix.PubSub.subscribe(Quic.PubSub, "session:" <> String.upcase(code))

    changeset = %Participant{} |> Participants.change_participant_validate(%{"name" => name},code)

    if Enum.count(changeset.errors) > 0 do
        [name: {msg, []}] = changeset.errors
        {:noreply, socket |> assign(error_name: msg, changeset: %{"code" => code, "name" => name})}

    else
      {:noreply, socket}
    end


    #assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"code" => code, "name" => username}, socket) do
    Phoenix.PubSub.subscribe(Quic.PubSub, "session:" <> String.upcase(code))
    Phoenix.PubSub.subscribe(Quic.PubSub, "session:" <> String.upcase(code) <> ":participant:" <> username)
    {:noreply, assign(socket, :code, code)}
  end


  def handle_info({"joined_session", %{"participant" => user}}, socket) do
    {:noreply, socket
              |> assign(:participant, user)
              |> redirect(to: ~p"/live-session/#{socket.assigns.code}/#{user.id}")}
  end

  def handle_info({"error_joining_session", %{"error" => msg}}, socket) do
    {:noreply, socket |> put_flash(:error, msg)}
  end

  def handle_info(_, socket), do: {:noreply, socket}





end
