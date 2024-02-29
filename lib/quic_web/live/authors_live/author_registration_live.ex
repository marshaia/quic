defmodule QuicWeb.AuthorRegistrationLive do
  use QuicWeb, :live_view

  alias Quic.Accounts
  alias Quic.Accounts.Author

  @spec render(any()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class="max-w-md mx-auto">
      <.header class="text-center">
        <h6>Register for an account</h6>
        <:subtitle>
          <span class="text-[var(--primary-color-text)]">Already registered?</span>
          <.link navigate={~p"/authors/log_in"} class="font-semibold text-brand hover:underline">
            Sign in
          </.link>
          <span class="text-[var(--primary-color-text)]">to your account now.</span>
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="registration_form"
        phx-submit="save"
        phx-change="validate"
        phx-trigger-action={@trigger_submit}
        action={~p"/authors/log_in?_action=registered"}
        method="post"
      >
        <.error :if={@check_errors}>
          Oops, something went wrong! Please check the errors below.
        </.error>

        <.input field={@form[:username]} type="text" label="Username" required />
        <.input field={@form[:display_name]} type="text" label="Email" required />
        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />

        <:actions>
          <.button phx-disable-with="Creating account..." class="w-full bg-[var(--primary-color)]">Create an account</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_author_registration(%Author{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"author" => author_params}, socket) do
    case Accounts.register_author(author_params) do
      {:ok, author} ->
        {:ok, _} =
          Accounts.deliver_author_confirmation_instructions(
            author,
            &url(~p"/authors/confirm/#{&1}")
          )

        changeset = Accounts.change_author_registration(author)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"author" => author_params}, socket) do
    changeset = Accounts.change_author_registration(%Author{}, author_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "author")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
