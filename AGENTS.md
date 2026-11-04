# AGENTS.md — Suspec canon

This repository owns Suspec's method, its decision history, and the skills that write Suspec
artifacts. It holds no runtime.

## Authority

- Accepted decisions: `docs/adrs/`. Never rewrite historical ADR bodies.
- Human artifact shapes: `docs/reference/artifact-formats.md`.
- Empirical sources: `docs/research/sources.md`.
- Artifact-author skills and their design evidence: `skills/`.
- Universal working methods: `jcosta33/skills`.

A contract change travels as a unit. Half-updated truth is still wrong.

## Writing

- Present current behavior in fresh-product language. Keep migration history inside ADRs.
- State delivery control honestly: `advisory`, `deterministic local`, or `isolated authority`.
  Otherwise name the enforcing command or owner.
- Use current artifact types only: spec, task, inventory, change plan, audit, research, and
  campaign. Evidence receipts and run notes are untyped sidecars.
- Publish no changing catalog, repository, artifact, or ADR totals. Decorative counts rot. Keep
  execution-defining floors, caps, versions, IDs, and exit codes exact.
- Cite every load-bearing empirical claim with `[[KEY]]` linked to
  `docs/research/sources.md#KEY`. Verify new sources before adding them.
- Put each rule in one authoritative document. Link from every secondary surface.

## Layout

- `docs/`: guide, reference, decisions, and evidence.
- `skills/`: artifact-author skills, their catalog, and their design evidence. Follow
  [the edit contract](skills/README.md) for every change under it.
- `scripts/`: the ADR seal and the skill gate, run together by `lint-all.sh`.

## Command

| Slot       | Command                  |
| ---------- | ------------------------ |
| `cmdCheck` | `sh scripts/lint-all.sh` |

Work from `main`; commit and push directly. `CLAUDE.md` and `GEMINI.md` point here.
