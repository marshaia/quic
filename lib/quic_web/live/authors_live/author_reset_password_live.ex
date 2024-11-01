defmodule QuicWeb.AuthorResetPasswordLive do
  use QuicWeb, :live_view

  alias Quic.Accounts

  def render(assigns) do
    ~H"""
    <div class="max-w-md px-4 py-4 mx-auto mt-10">
      <.header class="text-center">Reset Password</.header>

      <.simple_form
        for={@form}
        id="reset_password_form"
        phx-submit="reset_password"
        phx-change="validate"
      >
        <.error :if={@form.errors != []}>
          Oops, something went wrong! Please check the errors below.
        </.error>

        <.input field={@form[:password]} type="password" label="New password" required />
        <.input
          field={@form[:password_confirmation]}
          type="password"
          label="Confirm new password"
          required
        />
        <:actions>
          <.button phx-disable-with="Resetting..." class="w-full call2actionBtn"><p class="font-normal text-white">Reset Password</p></.button>
        </:actions>
      </.simple_form>

      <p class="mt-4 text-sm text-center">
        <.link href={~p"/authors/register"} class="hover:text-gray-500">Register</.link>
        | <.link href={~p"/authors/log_in"} class="hover:text-gray-500">Log in</.link>
      </p>
    </div>
    """
  end

  def mount(params, _session, socket) do
    socket = assign_author_and_token(socket, params)

    form_source =
      case socket.assigns do
        %{author: author} ->
          Accounts.change_author_password(author)

        _ ->
          %{}
      end

    {:ok, socket |> assign(:page_title, "Reset Password") |> assign_form(form_source), temporary_assigns: [form: nil]}
  end

  # Do not log in the author after reset password to avoid a
  # leaked token giving the author access to the account.
  def handle_event("reset_password", %{"author" => author_params}, socket) do
    case Accounts.reset_author_password(socket.assigns.author, author_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Password reset successfully.")
         |> redirect(to: ~p"/authors/log_in")}

      {:error, changeset} ->
        {:noreply, assign_form(socket, Map.put(changeset, :action, :insert))}
    end
  end

  def handle_event("validate", %{"author" => author_params}, socket) do
    changeset = Accounts.change_author_password(socket.assigns.author, author_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_author_and_token(socket, %{"token" => token}) do
    if author = Accounts.get_author_by_reset_password_token(token) do
      assign(socket, author: author, token: token)
    else
      socket
      |> put_flash(:error, "Reset password link is invalid or it has expired.")
      |> redirect(to: ~p"/")
    end
  end

  defp assign_form(socket, %{} = source) do
    assign(socket, :form, to_form(source, as: "author"))
  end
end
