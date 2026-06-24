# 0001 — Record architecture decisions

- **Status:** Accepted
- **Date:** 2026-06-24
- **Deciders:** project maintainers

## Context and problem statement

We want significant architectural and technical decisions to be discoverable and
to carry their rationale, so that future maintainers — and LLM coding agents
working in this repo — understand *why* the code is the way it is, and do not
"fix" intentional constraints. We need a lightweight, machine-readable format.

## Decision drivers

- Agents and newcomers need rationale, not just the current state of the code.
- The format must be low-friction so decisions actually get recorded.
- It should be greppable / machine-readable (status, date, structured sections).

## Considered options

- **MADR** (Markdown Any Decision Records) — structured, popular, simple.
- Free-form docs in a wiki — easy to write, hard to navigate/keep in sync.
- No formal records — lowest effort, highest long-term cost.

## Decision outcome

Chosen option: **MADR-format ADRs under `docs/design/adr/`**, one file per
decision, sequentially numbered (`NNNN-slug.md`), based on
[`template.md`](template.md). Each ADR has a machine-readable `Status:` and
`Date:` header.

### Consequences

- Positive: decisions are versioned with the code, reviewable in PRs, and easy
  for agents to locate and reason about.
- Negative: a small per-decision authoring cost; ADRs must be kept up to date
  (superseding rather than editing accepted ones).

## Confirmation

New architectural decisions are expected to arrive with an ADR in the same PR;
AGENTS.md instructs agents to add one (and request human sign-off) for such
changes.

## More information

- MADR: https://adr.github.io/madr/
- Architecture overview: ../architecture-overview.md
