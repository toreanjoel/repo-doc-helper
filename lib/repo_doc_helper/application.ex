defmodule RepoDocHelper.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do

    children = [
      # Start the Telemetry supervisor
      RepoDocHelperWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: RepoDocHelper.PubSub},
      # Start the Endpoint (http/https)
      RepoDocHelperWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RepoDocHelper.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # This needs to be done first, if there is no data we dont allow execution and let user know
  IO.inspect("We need to call the route to init the data before anything can be done")

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RepoDocHelperWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
