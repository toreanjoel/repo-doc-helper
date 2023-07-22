defmodule RepoDocHelper.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # startup functions
    Helpers.Directory.init_data()

    children = [
      # Start the Telemetry supervisor
      RepoDocHelperWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: RepoDocHelper.PubSub},
      # Start the Endpoint (http/https)
      RepoDocHelperWeb.Endpoint,
      # Start a worker by calling: RepoDocHelper.Worker.start_link(arg)
      # {RepoDocHelper.Worker, arg}
      # CUSTOM PROCESSES
      {RepoDocHelper.Supervisors.RepoFetch,
        %{
          :interval => System.get_env("REPO_FETCH_INTERVAL"),
          :repo => System.get_env("REPO_URL")
        }
      }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RepoDocHelper.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RepoDocHelperWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
