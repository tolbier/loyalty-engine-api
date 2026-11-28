defmodule LoyaltyEngineApi do
  @moduledoc """
  The entrypoint for defining the HTTP interface: routers, controllers, and
  channels.

  This can be used in your application as:

      use LoyaltyEngineApi, :controller

  The definitions below will be executed for every controller, channel, and so
  on, so keep them short and focused on imports, uses, and aliases.

  Do NOT define functions inside the quoted expressions below. Instead, define
  additional modules and import those modules here.
  """

  use Boundary, deps: [LoyaltyEngine], exports: []

  @spec router() :: Macro.t()
  def router do
    quote do
      use Phoenix.Router, helpers: false

      # Import common connection and controller functions to use in pipelines
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  @spec channel() :: Macro.t()
  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  @spec controller() :: Macro.t()
  def controller do
    quote do
      use Phoenix.Controller, formats: [:json]

      import Plug.Conn

      unquote(verified_routes())
    end
  end

  @spec verified_routes() :: Macro.t()
  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: LoyaltyEngineApi.Endpoint,
        router: LoyaltyEngineApi.Router
    end
  end

  @doc """
  When used, dispatch to the appropriate router, controller, or channel.
  """
  @spec __using__(atom()) :: Macro.t()
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
