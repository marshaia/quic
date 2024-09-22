defmodule QuicWeb.AuthorSettingsLive do
  use QuicWeb, :author_live_view

  alias Quic.Accounts

  def render(assigns) do
    ~H"""
    <main class="w-full">
      <.header class="mt-8 text-center">
        <h4>Account Settings</h4>
        <:subtitle>
          <p>Manage your account and password settings</p>
        </:subtitle>
      </.header>

      <div class="flex flex-col items-center justify-center">
        <%!-- <div class="lg:-mt-8 lg:w-1/2">
          <.simple_form
            for={@email_form}
            id="email_form"
            phx-submit="update_email"
            phx-change="validate_email"
          >
            <.input field={@email_form[:email]} type="email" label="Email" required />
            <.input
              field={@email_form[:current_password]}
              name="current_password"
              id="current_password_for_email"
              type="password"
              label="Current password"
              value={@email_form_current_password}
              required
            />
            <:actions>
              <.button phx-disable-with="Changing..." class="call2actionBtn"><p class="font-normal text-white">Change Email</p></.button>
            </:actions>
          </.simple_form>
        </div>

        <div class="border-b md:border-l border-[var(--border)] lg:mt-0 lg:mb-0 mt-3 -mb-7"></div>

        <div class="lg:-mt-8 lg:w-1/2">
          password form
        </div> --%>
        <%!-- PERSONAL INFO FORM --%>
        <.simple_form
          :let={f}
          for={@form}
          id="settings_info_form"
          phx-submit="save_info"
          phx-change="validate_info"
          class="w-full max-w-2xl"
        >
          <.error :if={@check_errors}>
            Oops, something went wrong! Please check the errors below.
          </.error>

          <.input field={f[:username]} type="text" label="Username" placeholder="pg12345" required />
          <.input field={f[:display_name]} type="text" label="Display Name" placeholder="Jane Doe" required />
          <.input field={f[:email]} type="email" label="Email" placeholder="email@domain.com" required />

          <:actions>
            <.button phx-disable-with="Saving..." class="call2actionBtn">
              <p class="text-base font-normal text-white">Save</p>
            </.button>
          </:actions>
        </.simple_form>

        <hr class="my-10" />

        <%!-- PASSWORD FORM --%>
        <.simple_form
          for={@password_form}
          id="password_form"
          action={~p"/authors/log_in?_action=password_updated"}
          method="post"
          phx-change="validate_password"
          phx-submit="update_password"
          phx-trigger-action={@trigger_submit}
          class="w-full max-w-2xl"
        >
          <.input
            field={@password_form[:email]}
            type="hidden"
            id="hidden_author_email"
            value={@current_email}
          />
          <.input field={@password_form[:password]} type="password" label="New password" required />
          <.input
            field={@password_form[:password_confirmation]}
            type="password"
            label="Confirm new password"
          />
          <.input
            field={@password_form[:current_password]}
            name="current_password"
            type="password"
            label="Current password"
            id="current_password_for_password"
            value={@current_password}
            required
          />
          <:actions>
            <.button phx-disable-with="Changing..." class="call2actionBtn"><p class="font-normal text-white">Change Password</p></.button>
          </:actions>
        </.simple_form>

        <hr class="my-10" />

        <.button
          phx-click="delete_account"
          data-confirm="Are you sure? Once deleted, all of your information will be removed and it cannot be retrived!!!"
          class="flex items-center gap-2 mt-2 h-9 bg-red-700 px-4 py-0.5 hover:bg-red-900"
        >
          <Heroicons.trash class="w-5 h-5" />
          <span class="font-normal text-white">DELETE ACCOUNT</span>
      </.button>
      </div>
    </main>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_author_email(socket.assigns.current_author, token) do
        :ok -> put_flash(socket, :info, "Email changed successfully.")
        :error -> put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/authors/settings")}
  end

  def mount(_params, _session, socket) do
    author = socket.assigns.current_author
    #email_changeset = Accounts.change_author_email(author)
    password_changeset = Accounts.change_author_password(author)

    socket = socket
      |> assign(:current_password, nil)
      #|> assign(:email_form_current_password, nil)
      |> assign(:current_email, author.email)
      |> assign(:form, Accounts.author_settings_changeset(author, %{}))
      #|> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:trigger_submit, false)
      |> assign(:page_title, "Settings")
      |> assign(:check_errors, false)

    {:ok, socket}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket |> assign(:current_path, "/authors/settings")}
  end

  # def handle_event("validate_email", params, socket) do
  #   %{"current_password" => password, "author" => author_params} = params

  #   email_form =
  #     socket.assigns.current_author
  #     |> Accounts.change_author_email(author_params)
  #     |> Map.put(:action, :validate)
  #     |> to_form()

  #   {:noreply, assign(socket, email_form: email_form, email_form_current_password: password)}
  # end

  # def handle_event("update_email", params, socket) do
  #   %{"current_password" => password, "author" => author_params} = params
  #   author = socket.assigns.current_author

  #   case Accounts.apply_author_email(author, password, author_params) do
  #     {:ok, applied_author} ->
  #       Accounts.deliver_author_update_email_instructions(
  #         applied_author,
  #         author.email,
  #         &url(~p"/authors/settings/confirm_email/#{&1}")
  #       )

  #       info = "A link to confirm your email change has been sent to the new address."
  #       {:noreply, socket |> put_flash(:info, info) |> assign(email_form_current_password: nil)}

  #     {:error, changeset} ->
  #       {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
  #   end
  # end

  def handle_event("validate_info", %{"author" => params} = _params, socket) do
    author_changeset =
      socket.assigns.current_author
      |> Accounts.author_settings_changeset(params)
      |> Map.put(:action, :validate)
      |> Map.put(:action, :validate_email)

    {:noreply, assign(socket, form: author_changeset)}
  end


  def handle_event("save_info", %{"author" => params} = _params, socket) do
    author = socket.assigns.current_author

    case Accounts.update_settings_info(author, params) do
      {:ok, author} ->
        changeset = Accounts.author_settings_changeset(author, %{})
        {:noreply, socket |> assign(check_errors: false) |> assign(:form, changeset) |> put_flash(:info, "Profile changes saved!")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign(:form, changeset)}
    end
  end



  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "author" => author_params} = params

    password_form =
      socket.assigns.current_author
      |> Accounts.change_author_password(author_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "author" => author_params} = params
    author = socket.assigns.current_author

    case Accounts.update_author_password(author, password, author_params) do
      {:ok, author} ->
        password_form =
          author
          |> Accounts.change_author_password(author_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, password_form: password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end


  def handle_event("delete_account", _params, socket) do
    case Accounts.delete_author(socket.assigns.current_author) do
      {:ok, _} -> {:noreply, socket |> Map.delete(:current_author) |> put_flash(:info, "Account deleted successfully!") |> redirect(to:  ~p"/")}

      {:error, _} ->
        {:noreply, socket |> put_flash(:error, "Error deleting account. Please try again!")}
    end
  end
end
