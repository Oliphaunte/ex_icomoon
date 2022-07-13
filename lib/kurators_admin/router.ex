defmodule KuratorsAdmin.Router do
  use KuratorsAdmin, :router

  alias KuratorsAdmin.{OnMount, Nav}
  alias Kurators.Auth.Plugs.{Role, Session, Callback}

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {KuratorsAdmin.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :callback do
    plug(Callback)
  end

  pipeline :session do
    plug(Session)
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", KuratorsAdmin do
    pipe_through [:browser, :callback]

    live("/auth/google", AuthLive, :index)
  end

  scope "/", KuratorsAdmin do
    pipe_through [:browser, :session]

    live("/auth", AuthLive, :index)

    live_session :authenticated,
      on_mount: [{OnMount, :check_authenticated}, Nav] do
      live "/", IndexLive, :index
      live("/settings/auth", WebAuthLive, :index)
    end
  end

  # scope "/", KuratorsWeb do
  #   pipe_through :browser

  #   live("/:route", CustomPageLive, :index)
  # end

  # Other scopes may use custom stacks.
  # scope "/api", KuratorsAdmin do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: KuratorsAdmin.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
