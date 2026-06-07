# decisions/

**Architecture Decision Records (ADRs)** — the project-wide decisions that shaped this repo. One decision per
file, **sequentially numbered** (`0001-`, `0002-`, …), in decision order. An ADR is **immutable**: to change a
past decision you write a new ADR that supersedes it (set the old one's status to `superseded`), never edit
the old body. That chain is the record of *why* the repo is the way it is.

This is the home for the one artifact that is genuinely **project-wide** rather than tied to a single feature.
Everything feature-scoped (a spec and its audit / research / bug-report / …) lives in its own
`specs/<feature>/` folder; durable findings live in `.agents/memory/`.

Copy `.agents/templates/adr.md` to start one. `0001-adopt-swarm.md` is a seed example — keep it (it records
*this* decision) or replace it.
