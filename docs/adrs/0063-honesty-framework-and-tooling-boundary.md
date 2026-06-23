---
type: adr
id: adr-0063
status: accepted
created: 2026-06-11
updated: 2026-06-11
---

# ADR-0063 — The honesty framework and the tooling boundary

## Context

A markdown-only framework cannot enforce anything; presenting conventions as enforcement is the fastest
way to lose a senior engineer's trust (adopter audit O-003/O-004/O-009/O-012: "lint floors" with no
linter, a "HARD CAP" with no checker, a versioned "language" with no parser). Meanwhile comparable tools
ship working validators, so "rules without a checker" has a short credibility window.

## Decision

1. **Every normative-sounding rule carries one of four levels:**
   - **convention** — expected practice; nothing enforces it;
   - **checklist** — review is expected to inspect it;
   - **toolable** — a named (future or optional) tool can check it;
   - **enforced** — a shipped tool actually enforces it (today: nothing qualifies).
     Approved wordings: _"This is a convention — nothing in this repository enforces it."_ /
     _"A future `corpus spec check` should flag this; until then, treat it as a review checklist item."_
     Banned wordings: "this fails lint", "this blocks merge", "this is enforced" (without a shipped tool).
2. **Check codes are review checklists.** The `SOL-XNNN` catalogue survives in
   `docs/reference/checks.md` as "common mistakes to check for", each row carrying its level — never
   "floors", "defects", or "BLOCKING" as if automated. Core checks (both spec forms): unique IDs · a
   `Verify with:` per requirement · one strength word per requirement · Non-goals present · Open
   questions present · no `TBD` at `status: ready` · sources named. Severity is a two-way split: hard
   errors (a checker must reject) vs warnings (a checker should flag) — the contract `corpus spec check`
   implements.
3. **corpus-cli is the reference implementation** of the checks contract, named in `checks.md`. The
   validator ships early — it is the credibility anchor for every "toolable" label.
4. **Length guidance is honest:** the agent-context file guidance is _"aim for ~100 lines"_ — Corpus's own
   convention, motivated directionally by instruction-density findings and vendor file-size bounds, not an
   ecosystem-derived number. No cap language, no fictional regression checks, anywhere.

## Alternatives considered

| Alternative                           | Why weaker                                                                                        |
| ------------------------------------- | ------------------------------------------------------------------------------------------------- |
| Keep normative MUST/BLOCKING language | Documented trust-killer with no enforcement behind it                                             |
| Drop the check codes entirely         | corpus-cli already builds against them; checklists with stable IDs are genuinely useful in review |

## Consequences

Positive: every claim auditable by grep ("enforced" only with a shipped tool). Negative: prose gets
slightly longer (level tags). Neutral: strict-mode policies remain a team choice ("teams may treat this
as blocking by policy").

## Status

Accepted. Refines ADR-0023, ADR-0026, ADR-0034, ADR-0043, ADR-0055; operationalizes the soft/hard-control
principle.

## Propagation

Every prose surface; checks.md owns the legend; kit cards; conformance README; corpus-cli.
