defmodule LoyaltyEngine.Repo do
  use Ecto.Repo,
    otp_app: :loyalty_engine,
    adapter: Ecto.Adapters.Postgres
end
