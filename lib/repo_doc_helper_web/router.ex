defmodule RepoDocHelperWeb.Router do
  use RepoDocHelperWeb, :router
  alias RepoDocHelperWeb.Api.QueryController, as: QueryController

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {RepoDocHelperWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", RepoDocHelperWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # The API routes to query functions and data against the AI and the dataset initializex
  scope "/api" do
    post "/initialize", QueryController, :init_data
    post "/query", QueryController, :query
    get "/status", QueryController, :status
  end

  # Other scopes may use custom stacks.
  # scope "/api", RepoDocHelperWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard in development
  if Application.compile_env(:repo_doc_helper, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: RepoDocHelperWeb.Telemetry
    end
  end
end
