# LoyaltyEngineApi

The HTTP application of [Loyalty Engine API](../../README.md). It will own
routing, controllers, the JSON:API representation, and CORS.

Today it contains only the endpoint, an empty `/api` router scope, the generated
error renderer, and telemetry. There are no API routes yet.

## Rules

- It depends on `loyalty_engine`, and may use only the modules that the domain
  exports through its `Boundary` declaration. `Repo` is not one of them.
- It contains no business rules.

## Commands

Run the project from the repository root, as described in the
[root README](../../README.md). The structure is described in
[the architecture](../../docs/ARCHITECTURE.md), and its reasons in
[the design decisions](../../docs/DECISIONS.md).
