defmodule LoyaltyEngine.Application do
  # See https://elixir.hexdocs.pm/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      LoyaltyEngine.Repo,
      {DNSCluster, query: Application.get_env(:loyalty_engine, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: LoyaltyEngine.PubSub}
      # Start a worker by calling: LoyaltyEngine.Worker.start_link(arg)
      # {LoyaltyEngine.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: LoyaltyEngine.Supervisor)
  end
end
