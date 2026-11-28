# Requirements and implementation roadmap

This roadmap translates [the project brief](CHALLENGE.md) into small,
verifiable steps. It describes intended behavior, not completed implementation.
Implementation steps remain unchecked until reviewed and verified.

## Objective

Build the API of a small loyalty-points platform. Members have wallets, and
every successful earn or redeem operation creates an immutable transaction.

```text
API clients
  -> HTTP REST; later Phoenix Channels
  -> loyalty_engine_api -> loyalty_engine -> PostgreSQL
```

## Required data and results

| Concept or rule | Expected result |
| --- | --- |
| Member | A participant, with one wallet in the initial model |
| Wallet | Its balance is consistent with the history and never negative |
| `earn` | A positive integer amount is added and recorded |
| `redeem` | A positive integer amount is spent and recorded |
| Insufficient balance | The redemption is rejected |
| Failed operation | No partial database changes remain |
| Retry with an idempotency key | The movement is not applied twice |
| Concurrent redemptions | Balance and ledger stay consistent |

## Roadmap

Sections 1 to 4 cover Sprint 1. Sections 5 to 8 cover Sprints 2 to 5 and are
refined before they start.

### 1. Define the foundation contract

- [x] **1.1** Create `docs/ARCHITECTURE.md` and `docs/DECISIONS.md`. Review the
  project guidance named in section 2.1 of the brief, record which decisions
  apply, and resolve conflicts. Include the brief's two different bootstrap
  descriptions: the umbrella in section 2 and the single application command
  in LE-001.
- [x] **1.2** Decide the health response, its status, and whether liveness and
  readiness are separate.
- [x] **1.3** Decide the environment variables, safe local defaults, and the
  allowed local CORS origins.

Acceptance: the decisions and their reasons are documented, without presenting
planned behavior as implemented.

### 2. Prepare the backend

- [x] **2.1** Review the generated umbrella: the one-way dependency, the absence
  of HTML, assets, and LiveView views, the generated defaults to keep or
  remove, and the installed Elixir, OTP, and Phoenix versions. Configure the
  `Boundary` library according to decision D7.
- [ ] **2.2** Make local configuration environment-driven, including the
  database connection and `.envrc.example`. Review the committed development
  and test secrets, and verify local PostgreSQL with Docker Compose.

Acceptance: from a clean checkout, the documented commands start PostgreSQL,
run the tests, and start the API. No real credentials are committed.

### 3. Expose the health endpoint

- [ ] **3.1** Implement `GET /api/health` test first, with an API integration
  test and no secrets or internal diagnostics in the response.
- [ ] **3.2** Configure local CORS test first, according to step 1.3.

Acceptance: the endpoint returns the agreed JSON and status, and only the
configured origins are allowed by CORS.

### 4. Establish the quality baseline

- [ ] **4.1** Complete the setup, formatter, and test documentation, review the
  `.gitignore` files, and add a minimal CI workflow.

Acceptance: the checks pass locally and in CI, and the README explains
prerequisites, configuration, and startup.

### 5. Add members and wallets

- [ ] **5.1** Decide the Member and Wallet fields, constraints, response shapes,
  errors, and pagination. Start `docs/DATA_MODEL.md`.
- [ ] **5.2** Create members with their wallets in the domain, with migrations,
  constraints, and tests.
- [ ] **5.3** Query members and wallets through the domain's public API.
- [ ] **5.4** Expose member creation, listing, details, and wallet endpoints
  with API integration tests.

Acceptance: a member created through the API is persisted with a wallet and
listed. Invalid input gets a predictable error.

### 6. Build the points ledger

- [ ] **6.1** Decide the balance strategy: derived from the ledger or a
  transactional projection.
- [ ] **6.2** Decide the concurrency and locking strategy.
- [ ] **6.3** Decide the idempotency-key scope, retention, and
  duplicate-response semantics.
- [ ] **6.4** Model immutable transactions and their database constraints.
- [ ] **6.5** Implement atomic, idempotent earn operations.
- [ ] **6.6** Implement atomic, idempotent redemptions that reject insufficient
  balance.
- [ ] **6.7** Verify retries, partial failures, and concurrent redemptions
  against PostgreSQL.
- [ ] **6.8** Expose earn, redeem, and transaction history endpoints with API
  integration tests.

Acceptance: all initial business rules in section 4 of the brief are verified
through the domain and the API.

### 7. Introduce OTP for a concrete workflow

- [ ] **7.1** Choose an asynchronous workflow and decide its failure and retry
  behavior, including whether durable jobs are warranted.
- [ ] **7.2** Implement it under supervision, keeping durable state in
  PostgreSQL.
- [ ] **7.3** Verify process lifecycle and failure scenarios.

Acceptance: the chosen mechanism is justified by the workflow, and its failure
behavior is tested and documented.

### 8. Add real-time updates

- [ ] **8.1** Decide topics, event payloads, subscription access, and how a
  client recovers state after reconnecting.
- [ ] **8.2** Publish events only after successful database commits.
- [ ] **8.3** Expose the events through Phoenix Channels, testing subscription,
  payloads, and disconnect and reconnect behavior.

Acceptance: a subscribed client receives a confirmed movement, and a failed
operation publishes nothing.

## Acceptance checklist

This checklist covers Sprint 1. Later sprints use their section acceptance.

- [ ] `loyalty-engine-api` is its own Git repository.
- [ ] Phoenix is API-only.
- [ ] The repository has its own README and dependency management.
- [ ] PostgreSQL starts locally with Docker Compose.
- [ ] The API starts with environment-driven configuration, and no secrets or
  real credentials are committed.
- [ ] `GET /api/health` returns tested JSON with a success status and exposes no
  internal information.
- [ ] Liveness and readiness are documented if both are implemented.
- [ ] Quality commands are documented, minimal CI runs them, and `.gitignore`
  files exclude dependencies, build output, and secrets.
- [ ] The implementation and its trade-offs can be explained.

## Verification guidance

Use test-driven development for each meaningful behavior: see the test fail for
the intended reason, implement the smallest change, then refactor. Test business
rules in the domain, persistence and concurrency against PostgreSQL, and HTTP
contracts through the API. End-to-end tests are optional until the user journeys
justify them.

Prefix new test names and roadmap commit subjects with the corresponding
`[RM_X_Y]` step identifier, following the project instructions in
[AGENTS.md](../AGENTS.md).

## Scope and limitations

Product expansion (Sprint 6) and the deployment and portfolio milestone are
outside this initial roadmap. Plan them once the core workflow is stable,
checking current provider pricing and limits. Before public write access,
address authentication, demo isolation, rate limiting, and abuse prevention.

Do not add Kubernetes, distributed clustering, an event-sourcing framework,
GenServers for ordinary CRUD, real payments, or blockchain features.
