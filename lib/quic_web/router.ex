defmodule QuicWeb.Router do
  use QuicWeb, :router

  import QuicWeb.AuthorAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {QuicWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_author
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", QuicWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", QuicWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:quic, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: QuicWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", QuicWeb do
    pipe_through [:browser, :redirect_if_author_is_authenticated]

    live_session :redirect_if_author_is_authenticated,
      on_mount: [{QuicWeb.AuthorAuth, :redirect_if_author_is_authenticated}] do
      live "/authors/register", AuthorRegistrationLive, :new
      live "/authors/log_in", AuthorLoginLive, :new
      live "/authors/reset_password", AuthorForgotPasswordLive, :new
      live "/authors/reset_password/:token", AuthorResetPasswordLive, :edit
    end

    post "/authors/log_in", AuthorSessionController, :create
  end

  scope "/", QuicWeb do
    pipe_through [:browser, :require_authenticated_author]

    live_session :require_authenticated_author,
      on_mount: [{QuicWeb.AuthorAuth, :ensure_authenticated}] do
      live "/authors/settings", AuthorSettingsLive, :edit
      live "/authors/settings/confirm_email/:token", AuthorSettingsLive, :confirm_email
    end
  end

  scope "/", QuicWeb do
    pipe_through [:browser]

    delete "/authors/log_out", AuthorSessionController, :delete

    live_session :current_author,
      on_mount: [{QuicWeb.AuthorAuth, :mount_current_author}] do
      live "/authors/confirm/:token", AuthorConfirmationLive, :edit
      live "/authors/confirm", AuthorConfirmationInstructionsLive, :new
    end
  end
end
