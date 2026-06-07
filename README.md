# Swarm

**Swarm is a way to write software specs that AI agents can build from reliably.** You write the spec in
controlled Markdown; agents read it, implement it, and prove they met it. The **spec — not the code — is the
source of truth**, the way OpenAPI, Terraform, and Kubernetes treat a declared `spec` as authoritative and
reconcile reality against it.

This repository is **markdown only**. Nothing here runs: every "tool" Swarm describes — a linter, a planner,
a checker, a CLI — is a *contract a future tool could build against*, never code this repo ships.

- **The spec is the source.** Requirements are written as **SOL** obligations (the Swarm Obligation Language)
  inside ordinary `*.swarm.md` files — e.g. `WHEN the request fails THE client MUST retry once VERIFY BY
  test:cmdTest:retry`. Plain Markdown around them carries the explanation.
- **Agents do the work.** An agent takes a spec through a short set of **steps** — write it, sharpen it, plan
  it, implement it, prove it, review it, fold the learnings back — and the bar to merge is simple: **every
  required obligation has a passing proof.**

## The flow

Intent flows from rough inputs to durable knowledge through nine ordered steps:

```text
author → lint → improve → lower → decompose → implement → verify → review → promote
```

Research, audits, and bug reports become a `*.swarm.md` spec; it's sharpened and turned into a structured
form and a plan; the plan yields bounded work packets; an agent implements each and records what it did;
verification and review judge it against the spec's obligations; durable discoveries fold back into memory.

The notation is small and closed — **7 obligation block types**, **5 modals** (`MUST`/`MUST NOT`/`SHOULD`/
`SHOULD NOT`/`MAY`), proofs bound with `VERIFY BY <type>:<adapter>:<artifact>` across **9 proof types**, and
**7 verdicts**. The exact members of every set live in one place: [`docs/reference/cheatsheet.md`](docs/reference/cheatsheet.md).

## Where the files go

Swarm lives in a **spec / documentation repo** — where intent is authored and reviewed. **Code repos stay
pristine.** ([ADR-0050](docs/adrs/0050-swarm-is-a-spec-repo-discipline.md))

- A **spec repo** adopts the **starter kit** (the authoring skills, the rule cards, the templates). Specs
  live in **per-feature folders** — `specs/<feature>/` holds the contract plus its supporting docs (audit,
  research, …); decisions live in **`decisions/`** (numbered ADRs); durable memory in **`.agents/memory/`**.
  One spec can govern **many** code repos — obligation ids are namespaced (`spec-id#AC-001`).
- A **code repo** takes **almost nothing**: a good SOL spec is self-legible, so no rule cards and no specs go
  there. At most one optional `implement-and-verify` skill. The **PR** (naming the obligation ids it
  satisfies, with CI + review) is the record; durable outcomes flow back to the spec repo as linked PRs.
- **Co-located** (a solo project) does both in one repo.

`.agents/` holds only tooling; there's no `.swarm/` directory and no version file — to upgrade, re-copy the
kit. Nothing executes; the files are inert reference data and copyable templates.

## How to adopt

**→ [`docs/ADOPTING.md`](docs/ADOPTING.md)** has a single copy-paste prompt: hand it to your coding agent
and it pulls Swarm and integrates the right pieces, whether you're starting a fresh spec repo or adding to
an existing one.

## The one rule: NO RUNTIME

Swarm ships markdown, not software. Everything that "runs" is a contract a future tool builds against, never
something this repo executes — and a `PASS` verdict requires a real proof that actually ran, not a
structurally valid artifact [[REFLEXION]](docs/research/sources.md#REFLEXION). The full set of standing
principles is in [`docs/PRINCIPLES.md`](docs/PRINCIPLES.md); what Swarm deliberately is *not* is in
[`docs/NON-GOALS.md`](docs/NON-GOALS.md).

## Where the docs live

- [`docs/language/`](./docs/language/) — the SOL and APS references, the error catalogue, versioning.
- [`docs/model/`](./docs/model/) — [how Swarm works](./docs/model/how-swarm-works.md), the artifacts, source
  authority, and what makes a valid Swarm repo.
- [`docs/passes/`](./docs/passes/) — one page per step.
- [`docs/reference/`](./docs/reference/) — the [cheatsheet](./docs/reference/cheatsheet.md) (every closed
  set), proof types, the structured form, the promotion protocol, the glossary.
- [`docs/artifacts/`](./docs/artifacts/) — the contract for each artifact (spec, task, trace, review,
  finding, ADR, and the source-document types).
- [`docs/library/`](./docs/library/) — the authoring skills and the heuristic profiles.
- [`docs/adrs/`](./docs/adrs/) — the decision ledger.
- [`starter-kit/`](./starter-kit/) — the files an adopter copies (skills, reference cards, templates, and a
  scaffold).

Together, `docs/` + `starter-kit/` **are** Swarm; the references here are complete and defer to nothing else.

---

Swarm **v0.1** · language **SOL/0.1**, **APS 0.1**.
