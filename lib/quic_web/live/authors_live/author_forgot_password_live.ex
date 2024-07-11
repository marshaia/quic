defmodule QuicWeb.AuthorForgotPasswordLive do
  use QuicWeb, :live_view

  alias Quic.Accounts

  def render(assigns) do
    ~H"""
    <div class="max-w-md px-4 py-4 mx-auto mt-10">
      <.header class="text-center">
        <h6 class="font-bold">Forgot your password?</h6>
        <:subtitle><p>We'll send a password reset link to your inbox</p></:subtitle>
      </.header>

      <.simple_form for={@form} id="reset_password_form" phx-submit="send_email">
        <.input field={@form[:email]} type="email" placeholder="Email" required />
        <:actions>
          <.button phx-disable-with="Sending..." class="w-full call2actionBtn">
            <p class="font-normal text-white">Send password reset instructions</p>
          </.button>
        </:actions>
      </.simple_form>
      <p class="mt-8 text-sm text-center">
        <.link href={~p"/authors/register"} class="hover:text-gray-500">Register</.link>
        | <.link href={~p"/authors/log_in"} class="hover:text-gray-500">Log in</.link>
      </p>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:page_title, "Forgot Password") |> assign(form: to_form(%{}, as: "author"))}
  end

  def handle_event("send_email", %{"author" => %{"email" => email}}, socket) do
    if author = Accounts.get_author_by_email(email) do
      Accounts.deliver_author_reset_password_instructions(
        author,
        &url(~p"/authors/reset_password/#{&1}")
      )
    end

    info =
      "If your email is in our system, you will receive instructions to reset your password shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
