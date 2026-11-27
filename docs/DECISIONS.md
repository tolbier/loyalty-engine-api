# Design decisions

This document records design decisions, their reasons, and their consequences.
A decision describes what was agreed, not what is implemented. See
[the architecture](ARCHITECTURE.md) for the current state.

## D1. Keep decisions in this document

**Context.** Section 13 of [the brief](CHALLENGE.md) suggests ADRs under
`docs/architecture/` or another agreed location. The reference guide uses one
numbered file per decision under `docs/decisions/`.

**Decision.** This document is the agreed location.

**Reason.** One document is enough for a project of this size.

**Consequences.** Neither of those directories is created. A changed decision
is recorded here together with the reason for the change.

## D2. Use an umbrella with two applications

**Context.** Section 2 of the brief states that the backend is an umbrella with
two applications. LE-001 suggests `mix phx.new loyalty-engine-api --no-html
--no-assets`, a command that does not create an umbrella.

**Decision.** Keep the umbrella: `loyalty_engine` for the domain and
persistence, and `loyalty_engine_api` for HTTP. The dependency goes only from
the API to the domain. Section 2 replaces the LE-001 command.

**Reason.** The brief declares the umbrella as an explicit architectural
decision. Separate applications declare their own dependencies, which makes the
boundary between the domain and Phoenix explicit. A single application was the
alternative: it is simpler, but that boundary would rest only on conventions or
additional tooling.

**Consequences.** `loyalty-engine-api` names the repository, while
`loyalty_engine_api` names the HTTP application. The applications share the
configuration, lockfile, and build, and they are not deployed independently.
The shared build does not strictly prevent forbidden calls. D7 adds `Boundary`
to check the allowed dependencies.

## D3. Start from scratch

**Context.** Section 2 of the brief says that the backend will be bootstrapped
again, mentions an existing API contract and approved design decisions as
sources of requirements, and discusses earlier Git history.

**Decision.** The project starts from scratch. No code, API contract, or design
decision is carried over from an earlier version.

**Reason.** The project owner confirmed this starting point.

**Consequences.** This decision replaces that paragraph of the brief. The
requirements come from the brief, [the roadmap](REQUIREMENTS.md), and the
decisions in this document.

## D4. Follow JSON:API and postpone OpenAPI

**Context.** Section 2 of the brief mentions JSON:API and OpenAPI adapters.
Section 5 asks for JSON over HTTP with consistent shapes, and for a contract
that can be documented with OpenAPI later. The reference guide treats both as
optional.

**Decision.** The API follows the [JSON:API specification][jsonapi]. OpenAPI is
postponed and has no roadmap step yet.

**Reason.** JSON:API defines standard conventions for resources and errors, so
the project does not need to invent them. Plain JSON was the alternative: it is
simpler and less verbose, but every convention would be a project decision.

**Consequences.**

- Requests and responses with a body use the `application/vnd.api+json` media
  type.
- Resource identifiers are strings in responses, whatever their storage type.
- Errors use the top-level `errors` array. This replaces the reference guide's
  `error` object. Error codes must be stable and must not expose internal
  details.
- The generated error renderer and `:api` pipeline do not follow the
  specification yet and must be adapted.
- The health response must also be a valid JSON:API document. D8 defines it.

[jsonapi]: https://jsonapi.org/format/

## D5. Apply the reference guidance selectively

**Context.** Section 2.1 of the brief asks to follow the guidance of the
`ctv_os_phoenix_challenge` project where it fits. The review covered
`docs/project_guide/`, `docs/BOUNDARIES.md`, and `docs/REQUIREMENTS.md`, plus
the outline and selected passages of `docs/DOMAIN.md`.

**Decision.** Adopt, adapt, postpone, or discard the guidance as listed below.
The brief and later decisions prevail over the reference guidance.

**Reason.** The general principles fit this project. Its domain, tooling, and
some of its contracts do not, and several topics belong to later roadmap steps.

### Adopted

- Organize the domain by business capability. Each context has one public
  facade and owns its persistence.
- Controllers validate the shape of the input, call a facade, and translate the
  result. Business rules stay in the domain, which knows nothing about HTTP.
- Contexts use each other's public APIs and avoid Ecto associations to each
  other's schemas.
- Enforce invariants in the application and, where possible, in the database.
- One owner controls each transaction.
- Test each responsibility and the complete flow, with deterministic tests that
  do not rely on sleeping. Test concurrency with independent database
  connections.
- Before the first deployment, migrations build the current model from an empty
  database. Applied production migrations are never rewritten.

### Adapted

- The HTTP application named `example_app_web` in the guide corresponds to
  `loyalty_engine_api`.
- HTTP contracts and errors follow D4.
- The guide's document layout and templates are not copied. This project keeps
  the documents linked from the [README](../README.md), and will describe the
  data model in `DATA_MODEL.md`, starting in step 5.1.
- The Definition of Done in section 11 of the brief replaces the guide's
  delivery checklist.

### Postponed

| Topic | When it is decided |
| --- | --- |
| Identifiers, pagination, and error details | Step 5.1 |
| Balance, locking, and idempotency | Steps 6.1 to 6.3 |
| Releases, backups, and recovery | Before deployment |

The guide uses `/health` and `/ready`, while the brief requires
`GET /api/health`. The brief's path prevails, and D8 decides the rest.

D9 decides environment variables and CORS. The quality gate is decided in D6.
The guide treats `Boundary` as optional and uses behaviours only for real
boundaries; D7 goes further. D7 also decides who owns the transaction behind a
persistence port.

### Discarded

- LiveView guidance, which the brief excludes.
- The CTV OS domain, its importer, and its agent-specific instructions.
- The CTV OS boundary map. It describes another domain and keeps a mutual
  dependency between models, which this project should avoid.

## D6. Adopt the reference quality gate

**Context.** The brief asks for tests, formatting, and lint checks where
configured. The reference guide runs a single quality command, both locally and
in CI. The generated `precommit` alias rewrites the format instead of checking
it, and runs no static analysis or coverage.

**Decision.** Step 4.1 provides one command, used locally and in CI, that runs:

1. Compilation with warnings as errors.
2. A format check that does not rewrite files.
3. Credo in strict mode.
4. Dialyzer.
5. All tests, with at least 90% line coverage of the domain application.

**Reason.** A single command keeps local and CI checks equal. Dialyzer checks
the type specifications that the project requires, and adopting these tools
while the code base is small avoids a later cleanup.

**Consequences.** Credo and Dialyzer become new dependencies, and the first
Dialyzer run is slow. The coverage threshold is a minimum, not evidence that
business rules are verified. The API still requires its own tests, although it
is outside the coverage threshold. Until step 4.1, this gate does not exist.

## D7. Use a hexagonal architecture with enforced boundaries

**Context.** The brief asks for clear domain boundaries and warns against
unnecessary abstractions. The reference guide organizes code by business
capability, treats `Boundary` as optional, and uses ports only when a real
boundary needs them. The project owner wants this architecture to include
screaming architecture, hexagonal architecture with ports and adapters,
dependency injection, and boundaries.

**Decision.**

- **Screaming architecture.** Directories and modules are named after business
  capabilities.
- **Inbound side.** The public facade of each context is its inbound port. It
  needs no behaviour. The HTTP application is an inbound adapter.
- **Outbound ports.** External or replaceable dependencies get a port when they
  appear. Persistence also gets a port. A port is a behaviour owned by the
  context that uses it.
- **Persistence ports.** Their operations follow use cases, not generic reads
  and writes. Each contract states its guarantees, such as atomicity and
  idempotency. The adapter owns the transaction that provides them.
- **Dependency injection.** Configuration selects each adapter. The facade
  reads it and passes the adapter explicitly to the use case. Tests of a use
  case can pass a fake. No injection container is used.
- **Persistence code.** `Repo` and migrations stay in `loyalty_engine`. Ecto
  schemas and queries belong to the persistence adapter of their context. Use
  cases and rules use neither them nor `Repo`. No third application is added.
- **Enforcement.** Step 2.1 configures the `Boundary` library before any domain
  code exists. Boundaries are declared as modules appear.

**Reason.** The project owner wants these approaches in a project built to
learn. Ports make the dependencies of the core explicit, and `Boundary` checks
the allowed ones at compile time. Persistence is the main outbound dependency
planned so far. Operations that follow use cases keep concurrency guarantees
visible in the contract.

**Consequences.**

- There are more modules and indirection than in plain Phoenix contexts, even
  while each port has only one production adapter.
- Part of a rule, such as checking the balance safely during a redemption, must
  be guaranteed by the persistence adapter.
- A fake can verify orchestration, but not atomicity, locking, constraints, or
  idempotency. Adapters need tests against PostgreSQL.
- Port contracts use domain types, not Ecto schemas or changesets.
- A single transaction across contexts is not covered by this decision.
  Creating a member with its wallet may need one, so step 5.1 must decide the
  context limits and who owns that transaction.
- `Boundary` becomes a new dependency. It does not verify runtime behavior or
  database coupling, so reviews are still needed.

## D8. Expose a single readiness health endpoint

**Context.** The brief requires `GET /api/health` to return a successful JSON
response when the API is available. It leaves open whether the endpoint checks
the database, and notes that liveness and readiness have different meanings.
The reference guide uses separate endpoints for them.

**Decision.** `GET /api/health` is the only health endpoint, and it reports
readiness: it succeeds only if the API can query PostgreSQL. There is no
separate liveness endpoint.

| Result | Status | Body |
| --- | --- | --- |
| Ready | `200` | `{"meta": {"status": "ok"}}` |
| Database unavailable | `503` | See the error document below |

```json
{"errors": [{"status": "503", "code": "service_unavailable"}]}
```

Both responses use these rules:

- `Content-Type: application/vnd.api+json` and `Cache-Control: no-store`.
- No version, environment, time, server name, exception message, or connection
  detail.
- The endpoint works without an `Accept` header, with `*/*`, and with
  `application/vnd.api+json`.

The check works as follows:

- The controller calls the public `Health` facade, which uses an outbound port.
  A PostgreSQL adapter implements the port by running `SELECT 1`, and
  configuration selects it, as D7 requires.
- The facade returns a domain result, either `:ok` or
  `{:error, :unavailable}`, without HTTP details.
- The facade calls the port directly. This is an exception to the flow in D7,
  because a use case that only delegates would add nothing.
- The target time limit is two seconds, including the wait for a database
  connection. Step 3.1 verifies how to apply it with Ecto.

**Reason.** The project owner wants a single endpoint with readiness semantics.
A metadata-only document is valid JSON:API, while a resource would need an
artificial type and identifier. Disabling caches prevents an old response from
looking like a current check. Going through a port keeps the HTTP adapter away
from `Repo`, and a fake can reproduce the failure.

**Consequences.**

- A `200` means that the query worked at that moment. It does not prove that
  migrations are applied or that every operation works.
- A database outage produces a `503` even though the API is running. A platform
  should not restart the API because of it. How the deployment platform uses
  the endpoint must be decided before deployment.
- Frequent checks query the database and may prevent a provider from suspending
  it when idle. Review the check frequency and the cost with the provider.
- The adapter must be tested against PostgreSQL.
- General JSON:API content negotiation, including `406` and `415` responses, is
  decided in step 5.1. Until then, the API does not fully comply with that part
  of the specification.

## D9. Configure through environment variables and restrict CORS

**Context.** The brief asks for environment-driven configuration, safe example
files, local CORS, and CORS restricted to configured origins outside local
development. The generated development and test settings hardcode the database
connection, Docker Compose publishes PostgreSQL on every interface, and there
is no frontend client planned.

**Decision.**

### Environment variables

| Variable | Environments | When unset |
| --- | --- | --- |
| `PGHOST` | Development, test | `localhost` |
| `PGPORT` | Development, test | `5432` |
| `PGUSER` | Development, test | `postgres` |
| `PGPASSWORD` | Development, test | `postgres` |
| `PORT` | All | `4000` |
| `CORS_ALLOWED_ORIGINS` | All | No allowed origins |
| `DATABASE_URL` | Production | Startup fails |
| `SECRET_KEY_BASE` | Production | Startup fails |

- The other generated variables, `POOL_SIZE`, `ECTO_IPV6`,
  `DNS_CLUSTER_QUERY`, and `MIX_TEST_PARTITION`, keep their behavior.
- Database names stay fixed and different for development and test.
  `MIX_TEST_PARTITION` is still appended to the test database name.
- `.envrc.example` is committed, and `.envrc` stays ignored. `.envrc` is only
  needed to override defaults. It can be loaded with `source .envrc` or with
  `direnv`, which is optional.

### Local safety

- Docker Compose publishes PostgreSQL only on `127.0.0.1`, and uses the same
  configurable user, password, and port. It only sees variables loaded in the
  shell that runs it.
- The development and test `secret_key_base` values stay in the repository.
  They are for local use only and must never be reused in production.

### CORS

- `CORS_ALLOWED_ORIGINS` is a comma-separated list of exact origins with the
  form `http(s)://host[:port]`. `*` is not allowed.
- Tests configure a fixed fictitious origin.
- Allowed origins may use `GET` and `POST`, send the `Accept` and
  `Content-Type` headers, and make `OPTIONS` preflight requests.
- Browser credentials, such as cookies, are not allowed.
- Step 6.3 decides the idempotency key header, which must then be added to the
  allowed headers.

### Invalid values

The application does not start if a port is invalid, or if a CORS origin is `*`
or does not have the expected form. The error names the variable to fix and
does not show secrets.

**Reason.** Local defaults let the project run without extra setup, while
variables allow a different environment without editing code. Requiring the
variables was the alternative: it keeps local values in one place, but adds a
setup step and CI configuration. An empty origin list grants no browser access
until a client needs it. Failing at startup reveals a wrong configuration
early.

**Consequences.**

- A missing or unloaded `.envrc` silently uses the local defaults.
- Changing the database credentials does not change those of an already
  initialized PostgreSQL volume. The README must warn about it once the
  variables are supported.
- A browser client needs its origin added before it can call the API. CORS does
  not affect `curl` or server clients, and it is not authentication.
- Step 2.2 implements the variables and the Docker Compose changes, and step
  3.2 implements CORS.
