# Loyalty Engine API

## Project Brief & Working Agreement

**Version:** 1.0\
**Status:** Project foundation / Sprint 1\
**Purpose:** Technical learning project and public portfolio
application\
**Primary technologies:** Elixir, Phoenix, OTP, PostgreSQL

------------------------------------------------------------------------

## 1. Project overview

Loyalty Engine is a small, progressively extensible loyalty-points
platform. Members have wallets containing points. The system records
point movements (earning and redemption) and exposes them through an HTTP
API. This brief covers that backend API.

The project has two equally important goals:

1. **Build a credible software product:** a working application that
   can eventually be deployed publicly and demonstrated to recruiters
   or engineering interviewers.
2. **Learn through implementation:** deepen practical knowledge of
   Phoenix and OTP by building a system whose architecture and
   requirements can evolve over time.

This is not intended to be a tutorial CRUD application. The work should
introduce meaningful backend engineering concerns such as domain
modelling, transactional consistency, idempotency, concurrency,
supervision, asynchronous processing and real-time updates---at a pace
appropriate to each stage.

The initial product is deliberately small. Complexity should be
introduced only when a requirement justifies it.

## 2. Explicit architectural decision: an independent API

The backend, `loyalty-engine-api`, is a **fully independent application
in its own Git repository**. It owns its:

- Git repository and history
- dependencies and lockfiles
- README and developer setup instructions
- tests and quality tooling
- CI pipeline
- build and release process
- deployment configuration and lifecycle

Clients communicate with it through explicit network contracts:

- HTTP REST for request/response operations.
- Phoenix Channels over WebSockets for real-time updates when that
  phase is reached.

Clients must not depend on backend internals. The backend serves no user
interface, and Phoenix LiveView is not part of this learning project.

### Backend internal structure

The backend repository, `loyalty-engine-api`, will be an Elixir umbrella
project with two applications and a one-way dependency:

``` text
loyalty-engine-api/             # Independent backend Git repository
├── apps/
│   ├── loyalty_engine/          # Domain and persistence
│   └── loyalty_engine_api/      # Phoenix HTTP API adapter
├── config/
├── docs/
└── mix.exs                     # Umbrella project
```

`loyalty_engine` owns the business domain, contexts, Ecto schemas,
PostgreSQL repository, migrations and domain tests. It must not depend on
Phoenix or the HTTP application. `loyalty_engine_api` owns the Phoenix
endpoint, router, controllers, JSON:API and OpenAPI adapters, CORS policy,
and HTTP integration tests. It depends on `loyalty_engine` and calls its
public context APIs; the domain application must not depend on the API
application.

The Phoenix release deployed on Fly.io includes the API application and
its domain dependency.

The backend will be bootstrapped again from a clean umbrella scaffold
before domain implementation begins. The existing product brief,
requirements, API contract and approved design decisions remain the
source of requirements, but application code will be implemented anew
and will not be copied into the new applications. A clean scaffold by
itself does not erase earlier Git history; if a clean public history is
required, establish the new backend repository history separately before
publishing it.

## 2.1 Architectural decisions and project guidance

The backend should follow the architectural decisions and
engineering principles documented in the existing project at
`/home/toyos/Projects/Elixir/ctv_os_phoenix_challenge`. In particular, consult
its `docs/project_guide/` materials for architecture, boundaries, domain
modeling, interfaces, persistence, testing and quality, clean code, and
operations; also consult `docs/BOUNDARIES.md` and the relevant domain and
requirements documents for the project-specific decisions. Apply the decisions
that fit this project, adapting examples to the loyalty domain and the
API boundaries defined above. If a decision conflicts with this brief or a
later approved requirement, record and resolve the conflict explicitly
before implementation.

## 3. Learning objectives

### Elixir and Phoenix

- Build a Phoenix JSON API.
- Organise domain logic using Phoenix contexts.
- Use Ecto schemas, changesets, queries and migrations.
- Design REST endpoints and consistent error responses.
- Write meaningful ExUnit unit and integration tests.
- Understand transactions and database concurrency.
- Use Phoenix PubSub and Channels for real-time events.

### OTP

OTP is to be introduced **incrementally**, not imposed on the
application from day one.

Learn when and why to use:

- Processes and message passing
- GenServer
- Task and Task.Supervisor
- Supervisor and supervision trees
- Phoenix PubSub
- Process lifecycle and failure handling
- Oban or another durable job mechanism, if later requirements justify
  it
- Distribution and clustering only as an optional advanced exercise

Do not use GenServer as an in-memory replacement for PostgreSQL or as
the source of truth for wallet balances. Durable business state and
financial-like invariants belong in PostgreSQL transactions. OTP
processes should be introduced to solve actual process-lifecycle,
coordination or asynchronous-work problems.

### Engineering practices

- Test-driven development (TDD).
- Clear domain boundaries and explicit contracts.
- Small, reviewable increments.
- Useful documentation and architecture decision records (ADRs).
- CI and reproducible local development.
- Production-minded configuration and deployment.

## 4. Product scope

### Initial domain concepts

**Member**\
A person who participates in the loyalty programme.

**Wallet**\
The member's points wallet. A member has a wallet in the initial model.

**Transaction**\
An immutable record of a points movement. The first supported movement
types are:

- `earn`: points are added.
- `redeem`: points are spent.

The wallet balance should be derived from its transaction history, or
maintained as a carefully controlled projection whose consistency is
guaranteed transactionally. It must never be arbitrarily editable
through a generic update endpoint.

### Initial business rules

1. A points amount must be a positive integer.
2. An earn operation increases the wallet's points.
3. A redeem operation decreases the wallet's points.
4. A redemption must be rejected if the available balance is
   insufficient.
5. A successful points movement creates an immutable transaction
   record.
6. A failed operation must not leave partial database changes.
7. Operations must support an idempotency key so that retries do not
   apply the same movement twice.
8. Concurrent redemptions must not result in a negative wallet balance
   or inconsistent ledger.
9. The database is the source of truth for durable wallet and
   transaction state.
10. All domain rules must be enforced by the backend; client-side
    validation does not provide security or correctness.

The exact schema, locking strategy, balance projection strategy and
idempotency-key constraints are deliberate design topics for
implementation and review. Do not prematurely settle them without
considering the requirements and trade-offs.

## 5. Initial API direction

The API is JSON over HTTP. The following endpoints are an initial
target, not a requirement to implement all of them in Sprint 1.

| Method | Endpoint | Purpose |
| --- | --- | --- |
| `POST` | `/api/members` | Create a member |
| `GET` | `/api/members` | List members |
| `GET` | `/api/members/:id` | Retrieve member details |
| `GET` | `/api/members/:id/wallet` | Retrieve wallet and balance |
| `GET` | `/api/members/:id/transactions` | Retrieve transaction history |
| `POST` | `/api/members/:id/earn` | Add points |
| `POST` | `/api/members/:id/redeem` | Redeem points |

API conventions to establish as implementation begins:

- Consistent JSON response shapes.
- Appropriate HTTP status codes.
- Predictable validation and domain error responses.
- Pagination for collection endpoints when needed.
- Explicit idempotency-key handling for points operations.
- CORS restricted to configured client origins outside local
  development.
- An API contract that can later be documented with OpenAPI.

A health endpoint is required in Sprint 1:

`GET /api/health`

It should return a simple successful JSON response when the API is
available. Whether it also checks database connectivity should be
decided and documented separately; liveness and readiness checks have
different meanings.

## 6. Technology choices

### Backend

- Elixir
- Phoenix 1.8, API-only configuration
- Ecto
- PostgreSQL
- ExUnit
- Docker for local infrastructure and deployment packaging
- Phoenix PubSub and Channels in a later phase
- Oban only if durable background jobs become useful

### Infrastructure and delivery

Initial deployment direction:

- **Backend:** Fly.io, using a Docker image and Phoenix release.
- **Database:** Neon PostgreSQL initially, or another managed
  PostgreSQL service.
- **Source control and CI:** a GitHub repository with its own GitHub
  Actions workflow.

The target is a free or very low-cost deployment. Provider pricing, free
allowances, sleep/scale-to-zero behaviour, resource limits, bandwidth,
storage and database availability must be checked against current
official pricing before deployment. Do not assume that any provider
offers a permanently free always-on service or promise a zero monthly
cost.

A custom domain is optional. Provider subdomains are sufficient for the
first public demo.

## 7. Public demo safety

A later public-demo mode may provide sample data and a safe way for
visitors to try the API. Public demo access must not allow one visitor
to alter another visitor's data. Authentication, demo isolation, rate
limiting and abuse prevention must be considered before opening write
operations to the public.

## 8. Incremental roadmap

The roadmap is intentionally evolutionary. Sprint boundaries can change
as implementation reveals better design choices.

### Sprint 1 --- Foundation

**Goal:** the API runs locally; PostgreSQL is available; the backend
exposes a tested health endpoint.

- Create the backend Git repository.
- Bootstrap Phoenix API-only backend.
- Configure PostgreSQL using Docker Compose for local development.
- Add environment-based configuration and safe example environment
  files.
- Implement and test `GET /api/health`.
- Configure local CORS.
- Add initial test and quality commands.
- Document setup and execution.

### Sprint 2 --- Domain and persistence

**Goal:** create members and wallets with tested domain behaviour.

- Model Member and Wallet.
- Add Ecto migrations and constraints.
- Implement member creation and listing.
- Add context-level tests and API integration tests.

### Sprint 3 --- Points ledger

**Goal:** implement earn and redeem safely.

- Model immutable Transactions.
- Implement earn and redeem operations.
- Reject invalid amounts and insufficient balance.
- Guarantee atomic updates.
- Add idempotency handling.
- Test failure cases, retries and concurrent operations.
- Expose wallet balance and transaction history.

### Sprint 4 --- OTP and asynchronous processing

**Goal:** introduce OTP where a concrete use case requires it.

- Identify a suitable asynchronous workflow.
- Introduce a supervised process or task-based mechanism.
- Define failure and retry behaviour.
- Keep durable state in PostgreSQL.
- Add tests for process lifecycle and failure scenarios.

The exact OTP abstraction should be chosen after the workflow is
defined. Do not add GenServers merely to demonstrate that GenServer has
been used.

### Sprint 5 --- Real-time updates

**Goal:** deliver completed wallet movements to connected clients in
real time.

- Publish domain-relevant events after successful database commits.
- Use Phoenix PubSub and Channels.
- Let clients subscribe to the relevant wallet or member topic.
- Push an event when a transaction is confirmed.
- Test subscription, event payload and disconnect/reconnect behaviour.

### Sprint 6 --- Product expansion

Possible extensions, selected according to learning value:

- Multiple loyalty programmes.
- Rewards catalogue and redemption of rewards.
- Point expiration.
- Programme rules and conversion rates.
- Authentication and authorisation.
- Audit and administrative views.
- External partner integrations.
- Durable background jobs and scheduled work.
- Observability, metrics and structured logging.

### Deployment and portfolio milestone

Once the core workflow is stable:

- Build a Phoenix release and Docker image.
- Deploy the backend to Fly.io.
- Provision managed PostgreSQL.
- Configure secrets and environment variables.
- Configure CORS, HTTPS and health checks.
- Run migrations safely.
- Add a CI/CD pipeline.
- Publish architecture documentation and a demo walkthrough.

## 9. Sprint 1 --- detailed work plan

### LE-001 --- Bootstrap the API

**User story:**

As a developer, I want a standalone Phoenix API repository, so that the
backend can be developed, tested, versioned and deployed independently.

**Acceptance criteria:**

- [ ] `loyalty-engine-api` is its own Git repository.
- [ ] Phoenix is generated as an API-only application.
- [ ] The repository has its own README and dependency management.
- [ ] PostgreSQL can be started locally using Docker Compose.
- [ ] The API can be started locally.
- [ ] Configuration is environment-driven.
- [ ] No secrets or real credentials are committed.
- [ ] Basic setup and run commands are documented.

**Suggested bootstrap commands:**

From a chosen workspace directory:

``` bash
mix phx.new loyalty-engine-api --no-html --no-assets
```

If the Phoenix generator creates a Git repository automatically, verify
its location.

Exact commands and flags should be checked against the installed Phoenix
tooling version.

### LE-002 --- API health endpoint

**User story:**

As an API client developer, I want a health endpoint, so that clients
and the deployment platform can verify that the backend is responding.

**Acceptance criteria:**

- [ ] `GET /api/health` returns JSON.
- [ ] The response has an appropriate success status.
- [ ] A controller/API integration test verifies the response.
- [ ] The endpoint does not expose secrets or internal diagnostics.
- [ ] Liveness and readiness semantics are documented if both are
  implemented.

### LE-004 --- Quality and documentation baseline

- [ ] Formatter and test commands are documented.
- [ ] A minimal CI workflow runs the relevant checks.
- [ ] `.gitignore` files exclude generated dependencies, build output
  and local secrets.
- [ ] The README explains prerequisites, configuration and local
  startup.

## 10. TDD and collaboration agreement

The project will use **test-driven development** as the default working
method.

For each meaningful behaviour:

1. Clarify the requirement and acceptance criteria.
2. Write a test that expresses the expected behaviour.
3. Run it and confirm that it fails for the intended reason.
4. Implement the smallest reasonable change.
5. Run the test and confirm it passes.
6. Refactor while keeping the tests green.
7. Review edge cases and design trade-offs.

Testing should be appropriate to the layer:

- Domain/context tests for business rules.
- Database-backed tests for persistence and transaction behaviour.
- API integration tests for HTTP contracts.
- End-to-end tests only when the application has enough user journeys
  to justify them.

### AI-assisted working agreement

The assistant acts as a senior engineering reviewer, mentor and sparring
partner---not as an automatic code generator.

- Present work in small tasks with explicit acceptance criteria.
- Do not provide the entire implementation before the learner has
  attempted it.
- Review submitted code, tests and configuration.
- Explain design alternatives and trade-offs.
- Identify unnecessary abstractions and overengineering.
- Challenge decisions constructively.
- Require the learner to understand and explain code, including
  AI-assisted code.
- Do not move to the next task until the current acceptance criteria
  are met or an explicit scope adjustment is agreed.
- Preserve the independence of the API from its clients.

The learner writes and owns the implementation. The assistant helps with
requirements, test design, review, debugging and architectural
discussion.

## 11. Definition of Done

A task is done when:

- Its acceptance criteria are satisfied.
- Relevant automated tests pass.
- Formatting and lint checks pass where configured.
- Errors and edge cases have been considered.
- No secrets or unrelated generated files have been committed.
- The implementation is understandable and documented where necessary.
- The learner can explain the implementation and its trade-offs.

A sprint is done when its agreed outcomes work together locally and the
setup is reproducible from the repository documentation.

## 12. Non-goals for the initial release

Do not implement these prematurely:

- Microservices.
- Kubernetes.
- Distributed BEAM clustering.
- A complex event-sourcing framework.
- GenServers for ordinary database-backed CRUD.
- Authentication and complex roles before the core workflow exists.
- Blockchain or token issuance.
- Real payment processing.
- Production-scale infrastructure before there is a working MVP.

The loyalty domain is inspired by the general problem space of loyalty
platforms. This is an independent educational project and is not
affiliated with, endorsed by or intended to reproduce the proprietary
systems of qiibee or any other company.

## 13. Open decisions to resolve during implementation

These decisions should be made deliberately when the relevant
requirements arrive:

- Exact Elixir, OTP and Phoenix versions.
- Whether wallet balance is computed from the ledger or maintained as
  a transactional projection.
- Database locking and concurrency strategy for redemptions.
- Idempotency-key scope, retention and duplicate-response semantics.
- Whether members can have multiple wallets in a later domain model.
- API pagination and error-response conventions.
- Authentication and demo-user isolation strategy.
- The specific asynchronous workflow that justifies introducing OTP
  workers.
- Whether Oban is warranted.
- Exact deployment sizing and current provider costs.

Record important architectural choices as short ADRs under
`docs/architecture/` in the repository, or in a dedicated
documentation location agreed by the project.

## 14. First action

Start with **LE-001 --- Bootstrap the API**.

Create the repository, initialise the application, and provide:

1. The directory tree of the repository.
2. The generated Phoenix version.
3. The relevant configuration files.
4. The commands used to start the application.
5. Any errors or decisions encountered.

------------------------------------------------------------------------

**Project principle:** build a small, correct system first; introduce
complexity only when the product requires it; understand every
architectural decision.
