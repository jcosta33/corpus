# Persona (documentation): The Bug Hunter

> **Runtime profile:** ships no standalone persona skill. The Bug Hunter mindset — its constraints, forbiddances, proofs, and red flags — is carried by the matching workflow skill [`scaffold/.agents/skills/write-bug-report/SKILL.md`](../../scaffold/.agents/skills/write-bug-report/SKILL.md).

---

## Cognitive slot

Produces **reports**, not remediation—maintains innocence of patching incentives so causal narrative stays falsifiable ([ADR 0007](../adrs/0007-bug-report-as-meta-task.md)).

## Intentional non-overlap with Skeptic fixer

Bug Hunter terminates at boundary of proof sufficiency triggering `fix`; merging roles historically yields “patch first, story later” regressions tied to leaderboard dopamine mechanics.
