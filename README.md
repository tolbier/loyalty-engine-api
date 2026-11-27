# Loyalty Engine API

The backend of Loyalty Engine, a small loyalty-points platform built to learn
Phoenix and OTP. Members have wallets, and the system records the points they
earn and redeem. This repository contains only the HTTP API.

See [the project brief](docs/CHALLENGE.md) for requirements, constraints, and
the working agreement, [the implementation roadmap](docs/REQUIREMENTS.md) for
the planned steps, [the architecture](docs/ARCHITECTURE.md) for the current and
planned structure, and [the design decisions](docs/DECISIONS.md) for their
reasons. The behavior below describes the intended result. The
repository currently contains only the generated Phoenix umbrella: no health
endpoint or loyalty domain behavior is implemented yet.

## How it works

```text
API client -> HTTP JSON -> loyalty_engine_api -> loyalty_engine -> PostgreSQL
```

The repository is an Elixir umbrella with a one-way dependency:

- `loyalty_engine_api` is the Phoenix HTTP adapter. It will own routing,
  controllers, the JSON:API contract, and CORS.
- `loyalty_engine` owns the domain, Ecto schemas, repository, and migrations.
  It does not depend on Phoenix or on the API application.

PostgreSQL is the source of truth for wallets and point movements. OTP
processes and real-time updates are introduced only when a requirement
justifies them.

## Run

The scaffold needs Elixir, Docker with Compose, and the external `pgdata`
volume (create it once with `docker volume create pgdata` if it is missing).

```bash
docker compose up -d
mix setup
mix test
mix phx.server
```

The server listens on `http://localhost:4000`. The database connection is
currently set in `config/`; it does not read the variables in `.envrc` yet.

Once the health endpoint is implemented, this request will return a successful
JSON:API response when the API can query PostgreSQL:

```bash
curl http://localhost:4000/api/health
```

## Scope

In scope: a JSON API for members, wallets, and an immutable history of earn and
redeem movements, introduced in small increments with test-driven development.

Out of scope: user interfaces, Phoenix LiveView, authentication
before the core workflow exists, real payments, blockchain, Kubernetes, and
distributed BEAM clustering.

This is an independent educational project. It is not affiliated with or
endorsed by any loyalty company.
