---
type: adr
id: adr-0192
status: accepted
created: 2026-11-05
---

# ADR-0192 - Manual-only invocation

## Context

The four artifact authors carried descriptions written for discovery: "Use when…" clauses that
invite a harness to load a skill whenever a task looks like a match. The method's signal table read
the same way, as a list of situations in which an agent reaches for a skill.

José Costa, the owner, ruled on 2026-11-05: none of these skills should trigger by themselves; they
are only manually invoked, always in response to a failure, not as a means to prevent one.

Two harnesses enforce the choice. Claude Code's `disable-model-invocation: true` stops Claude from
loading a skill automatically and keeps its description out of context; `/name` still works. Codex
reads `agents/openai.yaml`; `policy.allow_implicit_invocation: false` stops Codex from selecting the
skill from the prompt, and explicit `$skill` invocation still works. Both are cited in
[`skills/sources.md`](../../skills/sources.md). Other harnesses, Gemini CLI among them, have no such
control.

[ADR-0189](./0189-four-artifact-authors.md) Decision 1 makes each author a standalone single-file
skill, and the edit contract allows only `SKILL.md` and Markdown in a skill folder. The Codex control
needs a second, non-Markdown file.

## Decision

1. **Manual only.** Every artifact author runs only when the human invokes it. An agent never
   invokes one on its own initiative.
2. **Response to failure.** Each description says to use the skill only when the user explicitly
   asks, usually after work failed for lack of the artifact, and ends with "Never invoke on your own
   initiative." The method frames its signal table as guidance for the human.
3. **Claude Code control.** Each `SKILL.md` frontmatter carries `disable-model-invocation: true`.
4. **Codex control.** Each skill ships `agents/openai.yaml` containing exactly
   `policy:` / `allow_implicit_invocation: false`. It is the only file other than `SKILL.md` a skill
   may ship.
5. **Gate.** `sh scripts/lint-artifact-skills.sh` requires the frontmatter flag, the description
   wording, and the exact `agents/openai.yaml`, and still rejects every other extra file or
   directory.
6. **Control strength.** Deterministic local in Claude Code and Codex, enforced by the harness.
   Advisory everywhere else, where the description is the only control.

## Narrowed decisions

- [ADR-0189](./0189-four-artifact-authors.md) Decision 1: a skill is `SKILL.md` plus the one
  `agents/openai.yaml`; all instructions stay in `SKILL.md`.
- [ADR-0190](./0190-tracker-first-and-shorter-authors.md) and
  [ADR-0191](./0191-author-refinements-and-adoption-residue.md): the descriptions they shaped now
  state manual-only invocation; the scope and exclusion clauses stand.

## Consequences

- Claude Code no longer spends context on the four descriptions until one is invoked.
- In harnesses without a control, an agent may still load a skill on a description match; only the
  wording argues against it.
- The installer must copy `agents/openai.yaml` for the Codex control to hold.

## Status

Accepted (2026-11-05). Narrows ADR-0189, ADR-0190, and ADR-0191.
