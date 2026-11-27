defmodule LoyaltyEngineApi.Router do
  use LoyaltyEngineApi, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", LoyaltyEngineApi do
    pipe_through :api
  end
end
