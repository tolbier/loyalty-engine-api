# LoyaltyEngine

The domain application of [Loyalty Engine API](../../README.md). It will own the
business rules, contexts, ports, persistence adapters, and migrations.

Today it contains only `LoyaltyEngine.Repo` and the supervision of the
repository and PubSub. There are no contexts, schemas, or migrations yet.

## Rules

- It does not depend on Phoenix or on `loyalty_engine_api`.
- Its `Boundary` declaration exports no modules. Each public module, such as a
  context facade, must be exported before the API can use it.

## Commands

Run the project from the repository root, as described in the
[root README](../../README.md). The structure is described in
[the architecture](../../docs/ARCHITECTURE.md), and its reasons in
[the design decisions](../../docs/DECISIONS.md).
