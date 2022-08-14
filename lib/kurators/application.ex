defmodule Kurators.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Kurators.Repo,
      # Start the Telemetry supervisor
      KuratorsWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Kurators.PubSub},
      # Start the Endpoint (http/https)
      KuratorsAdmin.Endpoint,
      KuratorsWeb.Endpoint,
      {Finch, name: Swoosh.Finch},
      # Start the auth supervisor
      Kurators.Auth.Supervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Kurators.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    KuratorsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
