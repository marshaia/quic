defmodule QuicWeb.AuthorConfirmationInstructionsLive do
  use QuicWeb, :live_view

  alias Quic.Accounts

  def render(assigns) do
    ~H"""
    <div class="max-w-sm mx-auto">
      <.header class="text-center">
        No confirmation instructions received?
        <:subtitle>We'll send a new confirmation link to your inbox</:subtitle>
      </.header>

      <.simple_form for={@form} id="resend_confirmation_form" phx-submit="send_instructions">
        <.input field={@form[:email]} type="email" placeholder="Email" required />
        <:actions>
          <.button phx-disable-with="Sending..." class="w-full">
            Resend confirmation instructions
          </.button>
        </:actions>
      </.simple_form>

      <p class="mt-4 text-center">
        <.link href={~p"/authors/register"}>Register</.link>
        | <.link href={~p"/authors/log_in"}>Log in</.link>
      </p>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket |> assign(form: to_form(%{}, as: "author")) |> assign(:page_title, "Confirm Instructions")}
  end

  def handle_event("send_instructions", %{"author" => %{"email" => email}}, socket) do
    if author = Accounts.get_author_by_email(email) do
      Accounts.deliver_author_confirmation_instructions(
        author,
        &url(~p"/authors/confirm/#{&1}")
      )
    end

    info =
      "If your email is in our system and it has not been confirmed yet, you will receive an email with instructions shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
