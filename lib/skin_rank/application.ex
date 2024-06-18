defmodule SkinRank.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SkinRankWeb.Telemetry,
      SkinRank.Repo,
      {DNSCluster, query: Application.get_env(:skin_rank, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: SkinRank.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: SkinRank.Finch},
      # Start a worker by calling: SkinRank.Worker.start_link(arg)
      # {SkinRank.Worker, arg},
      # Start to serve requests, typically the last entry
      SkinRankWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SkinRank.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SkinRankWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
