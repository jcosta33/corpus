# Skill (documentation): `adversarial-review`

> **For agents:** instructions → [`/scaffold/.agents/skills/adversarial-review/SKILL.md`](../../scaffold/.agents/skills/adversarial-review/SKILL.md)

---

## TL;DR

Friendly review praises intent; adversarial review **assigns probabilities of latent failure**. The skill biases acceptance toward disproof tries — property edges, concurrency windows, deceptive happy paths — and refuses to sign off on a worker's pasted output. It self-activates on any work that already exists to be reviewed (a branch, a follow-up revision, an audit you are deepening, a bug you are root-causing) and stays out of original authoring.

## What the skill actually enforces

The SKILL body is built around six adversarial questions walked in order on every diff — intent, does-the-code-do-it, what-didn't-change-that-should-have, unhandled edge cases, production failure modes, claimed-but-not-verified — plus a cross-module caller search (`git grep` every changed public surface and read the call sites, not just the modified module). Findings must carry severity, `file:line`, a specific issue, and a fix sketch; soft language and style preferences are not findings. The reviewer runs install, validate, and test **in their own worktree with the branch checked out** — the worker's pasted output is evidence the command ran at some past moment, not evidence it passes now.

## Why a skill and not just the Skeptic persona

The persona (`scaffold/.agents/skills/persona-skeptic/SKILL.md`) conveys stance breadth — the mindset for review-shaped and root-causing work. The skill isolates the reusable **attack-pattern kit** so any session reviewing existing work can load the six questions and the caller-search discipline without the persona carrying an encyclopaedic playbook. They compose: load the persona for mindset, the skill for the procedure. Neither is always-loaded — each fires on its own description when the task matches.

## Psychological basis

Contributor empathy correlates with under-weighting the malignant edge cases authored by oneself. Scripted scepticism substitutes for emotional distance without mandating hostile prose — the focus stays on falsifiable artefacts (file:line findings, rerun output), not tone.

## Design tension vs velocity

Exhaustive review does not scale by hand. The skill emphasises **risk-ranked** probes — severity mapped to blast radius — over academic completeness, and the bundled review template encodes that ordering in its Self-review scaffolding. Bounded kickback rounds keep the revision loop from running forever (see [flow graph](../concepts/07-flow-graph.md)).

## Interaction with empirical-proof

Adversarial review guides the *thinking* — which holes to probe. `empirical-proof` mandates the *executable* falsification: re-run the validators yourself, paste the verbatim output. Neither replaces the other; a review that reasons hostilely but trusts the worker's logs has skipped the proof.

## Failure modes

| Pitfall | Result |
|---------|--------|
| Review becomes tone policing | Misses behavioural holes while appearing thorough. |
| Trust the worker's logs | Violates rerun independence — defeats the adversarial framing. |
| Demote findings to MINOR to avoid blocking | Ships the defect with a paper trail that it was seen. |
| Review only the diff | Lifecycle and contract bugs in unchanged callers slip through. |

## Bundled resources

- `references/task-template.md` — a fillable review-session task template: diff overview, findings table, verdict, and a Self-review hard gate. Copy it into your task file, substitute the project-specific commands and slugs, and fill it in as you work.

## Related

- [Skeptic persona](../personas/the-skeptic.md) — mindset and routing context (ships as `persona-skeptic`)
- [Task: review](../tasks/review.md)
- [Empirical-proof skill](empirical-proof.md)
