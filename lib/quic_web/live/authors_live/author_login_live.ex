defmodule QuicWeb.AuthorLoginLive do
  use QuicWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="max-w-md px-4 py-4 mx-auto mt-10">
      <.header class="text-center">
        <h5>Sign in to account</h5>
        <:subtitle>
          <span class="text-[var(--primary-color-text)]">Don't have an account?</span>
          <.link navigate={~p"/authors/register"} class="font-semibold text-brand hover:underline">
            Sign up
          </.link>
          <span class="text-[var(--primary-color-text)]">for an account now.</span>
        </:subtitle>
      </.header>

      <.simple_form for={@form} id="login_form" action={~p"/authors/log_in"} phx-update="ignore" actionClass="justify-between">
        <.input field={@form[:email]} type="email" label="Email" placeholder="email@domain.com" required />
        <.input field={@form[:password]} type="password" label="Password" placeholder="*****" required />

        <:actions>
          <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
          <%!-- <.link href={~p"/authors/reset_password"} class="text-sm font-semibold">
            Forgot your password?
          </.link> --%>
        </:actions>
        <:actions>
          <.button phx-disable-with="Signing in..." class="w-full call2actionBtn">
            <p class="text-base font-normal text-white">Sign in</p>
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = live_flash(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "author")

    socket = socket
    |> assign(form: form)
    |> assign(page_title: "Login")

    {:ok, socket, temporary_assigns: [form: form]}
  end
end
