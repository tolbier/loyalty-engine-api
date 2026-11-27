# Project instructions

This file contains, and must only ever contain, generic guidelines that apply
to any Elixir/OTP project. Do not add project-specific libraries, modules,
architecture, or decisions here; record them in the documents under `docs/`
instead.

## Project collaboration preference

The user is implementing this challenge themselves. Act as a counselor: discuss
design choices and explain concepts, but do not inspect files, run commands,
write code, or make changes unless the user explicitly asks.

When the user resumes work on this challenge in a future conversation, read
`docs/DECISIONS.md` to recover the design decisions already made. The user has
explicitly requested this standing reference. Do not inspect other project files
unless the user explicitly asks.

## Code and architecture quality

The user wants the same clean code and architecture standards applied
consistently across all challenges and throughout this project. Review both
design and code as each roadmap step is implemented, while preserving the
collaboration preference above.

- Keep responsibilities clear and configuration and supervision straightforward.
- Keep the public API small and focused on what clients need to do and query;
  keep process and library internals behind it.
- Let the chosen OTP behaviours and libraries own what they are designed for,
  such as scheduling, concurrency, demand, or retries; do not reimplement
  their mechanisms by hand.
- Keep each process or worker focused on a single responsibility.
- Use precise names and types, small readable functions, and helpers whose names
  add meaning. Give functions with different responsibilities distinct names.
- Give every public function a `@spec`, including behaviour callbacks such as
  `init/1`, `handle_call/3`, `handle_demand/2`, and `start/2`. Name shared or
  nontrivial shapes with `@type` or `@typep` and use those names in the specs.
  Private functions and test support modules may omit specs.
- Choose pipelines or direct assignments based on readability of the operation.
- Add modules and abstractions when they serve a concrete responsibility; avoid
  unnecessary splitting or broad refactors solely for stylistic consistency.
- Keep current structure, responsibilities, and invariants in
  `docs/ARCHITECTURE.md`; record design reasoning and history in
  `docs/DECISIONS.md`.

## Architecture documentation

Create and maintain dedicated documents under `docs/` as needed to document
the project and its changes. Use `docs/ARCHITECTURE.md` for structure,
responsibilities, supervision, and behavior; use `docs/DATA_MODEL.md` for data
structures, fields, relationships, and invariants when needed. Link every
project documentation file from `README.md` and keep those links current.

Whenever you make changes to the project, review and update all affected
documentation without waiting for the user to request it. Keep
`docs/ARCHITECTURE.md`, including its diagrams, aligned with the current
implementation and design. Update `docs/DATA_MODEL.md`, `docs/DECISIONS.md`,
roadmap progress in `docs/REQUIREMENTS.md`, testing guidance, and the README
when affected. Include the necessary Mermaid diagrams alongside the prose in
`docs/ARCHITECTURE.md` to explain structure, supervision, data flow, and process
interactions as applicable. Add or revise these diagrams when the documented
structure or behavior changes. Do not describe planned behavior as already
implemented.

## Roadmap commit messages

For commits related to a numbered step in `docs/REQUIREMENTS.md`, prefix the
commit subject with `[RM_X_Y]`, where `X.Y` is the step number. For example,
changes for step 1.1 use `[RM_1_1]`.

## Roadmap test names

Prefix every new test name with `[RM_X_Y]`, using the current roadmap step.
Whenever a test is modified as part of a later roadmap step, update its
prefix to that step and adjust its descriptive title to match its body.
For example, a test extended in step 6.2 must start with `[RM_6_2]`, even if
it was introduced in an earlier step. Apply this convention to generated
test names too.

After changing a test's prefix, reorder it within its file by the numeric
roadmap step. Keep the existing order for tests from the same step, and move
tags and generated-test blocks together with their tests. This source order
does not change ExUnit's randomized execution order. Git history preserves
the origin and earlier versions of the tests.

## OTP reference material

The user uses *Designing Elixir Systems with OTP* as a reference:

- Book: `/home/toyos/Documents/Books/Elixir/Designing Elixir systems with OTP`
- Completed implementation:
  `/home/toyos/Projects/Elixir/designing-elixir-systems-with-otp/mastery`

The `mastery` project is tracked with Git and tagged by chapter, so its history
can be used to find the implementation corresponding to a chapter. Do not
inspect these resources unless the user explicitly asks.

## Markdown documentation

Whenever editing Markdown, keep it free of markdownlint errors. Use one
first-level title per document, consistent heading levels, one blank line
between blocks, and wrap prose and list items to 80 columns. Preserve code
blocks, inline code, links, and tables when wrapping.

Run `npx --yes markdownlint-cli2 'docs/*.md' AGENTS.md` after documentation
changes and fix reported issues before finishing. Use the repository
configuration; do not disable rules just to hide formatting errors.
