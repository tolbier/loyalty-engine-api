# Requirements and implementation roadmap

This roadmap translates [the project brief](CHALLENGE.md) into small,
verifiable steps. It describes intended behavior, not completed implementation.
Implementation steps remain unchecked until reviewed and verified.

## Objective

Build a small loyalty-points platform as two independent applications in
separate Git repositories. Members have wallets, and every successful earn or
redeem operation creates an immutable transaction.

```text
loyalty-engine-web (React)
  -> HTTP REST; later Phoenix Channels
  -> loyalty_engine_api -> loyalty_engine -> PostgreSQL
```

This roadmap lives in `loyalty-engine-api` and also tracks the steps done in
`loyalty-engine-web`. Frontend commits belong to that repository and use the
same step prefix.

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

Sections 1 to 5 cover Sprint 1. Sections 6 to 9 cover Sprints 2 to 5 and are
refined before they start.

### 1. Define the foundation contract

- [ ] **1.1** Create `docs/ARCHITECTURE.md` and `docs/DECISIONS.md`. Review the
  project guidance named in section 2.1 of the brief, record which decisions
  apply, and resolve conflicts. Include the brief's two different bootstrap
  descriptions: the umbrella in section 2 and the single application command
  in LE-001.
- [ ] **1.2** Decide the health response, its status, and whether liveness and
  readiness are separate.
- [ ] **1.3** Decide the environment variables, safe local defaults, and the
  allowed local CORS origins.

Acceptance: the decisions and their reasons are documented, without presenting
planned behavior as implemented.

### 2. Prepare the backend

- [ ] **2.1** Review the generated umbrella: the one-way dependency, the absence
  of HTML, assets, and LiveView views, the generated defaults to keep or
  remove, and the installed Elixir, OTP, and Phoenix versions.
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

### 4. Connect the frontend

- [ ] **4.1** Create `loyalty-engine-web` as its own Git repository with React,
  TypeScript, and Vite, and record the installed Node.js and React versions.
- [ ] **4.2** Add the API base URL as environment configuration with a safe
  example file.
- [ ] **4.3** Show API connectivity with loading, success, and error states,
  covered by a component or integration test.

Acceptance: both applications start independently, and the page reports whether
the API is reachable. The parent directory is not a Git repository.

### 5. Establish the quality baseline

- [ ] **5.1** Complete the backend setup, formatter, and test documentation,
  review its `.gitignore` files, and add a minimal CI workflow.
- [ ] **5.2** Document frontend setup, lint, test, and build commands, review
  its `.gitignore`, and add a minimal CI workflow.

Acceptance: each repository's checks pass locally and in its own CI, and its
README explains prerequisites, configuration, and startup.

### 6. Add members and wallets

- [ ] **6.1** Decide the Member and Wallet fields, constraints, response shapes,
  errors, and pagination. Start `docs/DATA_MODEL.md`.
- [ ] **6.2** Create members with their wallets in the domain, with migrations,
  constraints, and tests.
- [ ] **6.3** Query members and wallets through the domain's public API.
- [ ] **6.4** Expose member creation, listing, details, and wallet endpoints
  with API integration tests.
- [ ] **6.5** Add the React member list and creation form, with tests.

Acceptance: a member created from React is persisted with a wallet and listed.
Invalid input gets a predictable error.

### 7. Build the points ledger

- [ ] **7.1** Decide the balance strategy: derived from the ledger or a
  transactional projection.
- [ ] **7.2** Decide the concurrency and locking strategy.
- [ ] **7.3** Decide the idempotency-key scope, retention, and
  duplicate-response semantics.
- [ ] **7.4** Model immutable transactions and their database constraints.
- [ ] **7.5** Implement atomic, idempotent earn operations.
- [ ] **7.6** Implement atomic, idempotent redemptions that reject insufficient
  balance.
- [ ] **7.7** Verify retries, partial failures, and concurrent redemptions
  against PostgreSQL.
- [ ] **7.8** Expose earn, redeem, and transaction history endpoints with API
  integration tests.
- [ ] **7.9** Add the React member details, transaction history, and
  transaction form views, with tests.
- [ ] **7.10** Add the React dashboard of members and points activity, defining
  any endpoint it needs first.

Acceptance: all initial business rules in section 4 of the brief are verified,
and the UI shows success only after the backend confirms it.

### 8. Introduce OTP for a concrete workflow

- [ ] **8.1** Choose an asynchronous workflow and decide its failure and retry
  behavior, including whether durable jobs are warranted.
- [ ] **8.2** Implement it under supervision, keeping durable state in
  PostgreSQL.
- [ ] **8.3** Verify process lifecycle and failure scenarios.

Acceptance: the chosen mechanism is justified by the workflow, and its failure
behavior is tested and documented.

### 9. Add real-time updates

- [ ] **9.1** Decide topics, event payloads, subscription access, and how a
  client recovers state after reconnecting.
- [ ] **9.2** Publish events only after successful database commits.
- [ ] **9.3** Expose the events through Phoenix Channels, with tests.
- [ ] **9.4** Subscribe from React and update the UI, testing disconnect and
  reconnect behavior.

Acceptance: a confirmed movement appears in React without a page refresh, and
a failed operation publishes nothing.

## Acceptance checklist

This checklist covers Sprint 1. Later sprints use their section acceptance.

- [ ] A local parent directory exists and is not a Git repository.
- [ ] `loyalty-engine-api` and `loyalty-engine-web` are separate repositories.
- [ ] Phoenix is API-only, and React uses TypeScript and Vite.
- [ ] Each repository has its own README and dependency management.
- [ ] PostgreSQL starts locally with Docker Compose.
- [ ] Both applications start independently with environment-driven
  configuration, and no secrets or real credentials are committed.
- [ ] `GET /api/health` returns tested JSON with a success status and exposes no
  internal information.
- [ ] Liveness and readiness are documented if both are implemented.
- [ ] The React page calls the health endpoint using a configured base URL, not
  a hard-coded production URL.
- [ ] Loading, success, and error states are visible and tested.
- [ ] Quality commands are documented, minimal CI runs them in each repository,
  and `.gitignore` files exclude dependencies, build output, and secrets.
- [ ] The implementation and its trade-offs can be explained.

## Verification guidance

Use test-driven development for each meaningful behavior: see the test fail for
the intended reason, implement the smallest change, then refactor. Test business
rules in the domain, persistence and concurrency against PostgreSQL, HTTP
contracts through the API, and visible behavior with React component tests.
End-to-end tests are optional until the user journeys justify them.

Prefix new test names and roadmap commit subjects with the corresponding
`[RM_X_Y]` step identifier, following the project instructions in
[AGENTS.md](../AGENTS.md).

## Scope and limitations

Product expansion (Sprint 6) and the deployment and portfolio milestone are
outside this initial roadmap. Plan them once the core workflow is stable,
checking current provider pricing and limits. Before public write access,
address authentication, demo isolation, rate limiting, and abuse prevention.

Do not add Kubernetes, distributed clustering, an event-sourcing framework,
GenServers for ordinary CRUD, Redux, real payments, or blockchain features.
