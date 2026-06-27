---
type: adr
id: adr-0118
status: accepted
created: 2026-06-27
updated: 2026-06-27
---

# ADR-0118 — Numeric/adoption claims must be ground-truthed by live query, not voted from recall

## Context

The Phase 3 family-sweep (workflow `wf9rvvwys`) confirmed the re-architecture this program shipped was
correct in file structure — 8→6 agents, 7→11 skills, mcp 0.2.0, the [ADR-0112](./0112-two-tier-skills.md)
catalog/kit split all landed — but the doc/reference layer drifted, and every recurring issue in the
sweep mapped to a missing automated gate (a human caught it, not a check). One drift class surfaced in
the research workflow itself: the deep-research run **refuted a TRUE numeric claim** — a real GitHub
star count — and declared "no data exists," when the figure was live-queryable with one `gh api` call.
The adversarial panel voted down a *recalled* number instead of *checking* it. That is refute-by-default
([adversarial-review], [ADR-0095](./0095-review-model-grounding.md)) misfiring: the stance is meant to
withhold belief until evidence forces it, not to license dismissing a checkable fact without running the
check. A queryable metric is exactly the regime where agreement/recall is the wrong instrument and a
deterministic external lookup is the right one — the same deterministic-not-judge spine the framework
already rests on ([ADR-0063](./0063-honesty-framework-and-tooling-boundary.md),
[ADR-0043](./0043-checkable-documents.md): voting and self-consistency are not correctness signals; a
resolving check is).

## Decision

**Any claim about a queryable metric must be ground-truthed against a live primary source before it can
be marked Refuted or "no data exists."**

1. **What this covers.** Queryable metrics are facts a deterministic lookup can resolve *now*: counts
   (stars, downloads, contributors), released versions, file/path existence, and similar primary-source
   figures. The primary source is the authority itself — `gh api` for GitHub figures, the package
   registry for versions/downloads, the filesystem for existence — never a recalled number, a cached
   summary, or a panel's collective memory.

2. **No refute-by-recall.** A queryable claim may not be marked **Refuted** on the ground that the
   number "looks wrong" or "isn't remembered." Refute-by-default withholds belief; it does not authorize
   *disproving* a checkable fact without checking it. Surprise about a number is a trigger to query, not
   a verdict.

3. **"No data" is assertable only after a logged, failed live query.** "No data exists" is a claim about
   the world that itself requires evidence: the actual query that was run, its source, and its empty/error
   result, recorded inline. Absent that logged failed query, the honest verdict is **Unverified**, not
   Refuted and not "no data."

_Level: convention (method discipline)._ This rule is **in force now** for the deep-research and
adversarial-review workflows by discipline + review — it is how those workflows are expected to run today.
The **toolable path** is to wire it as a hard workflow step (a verify-before-refute gate on
queryable-claim verdicts that fails the step when a Refuted/"no data" verdict carries no logged live
query); **that step is not yet shipped** — until it lands, this is a review-checklist item, not an
enforced gate (no enforcement-sounding claim is made here per [ADR-0063](./0063-honesty-framework-and-tooling-boundary.md)).

## Consequences

- **Cost — a query per queryable claim before it can be killed.** Refuting "the repo has N stars" now
  requires one `gh api` call (and a recorded result) instead of a panel vote; cheap in tokens, but a
  real added step. The win is that a true fact can no longer be voted down from bad recall.
- **Sharper verdicts.** "No data exists" stops being a polite synonym for "nobody checked." It now means
  a query ran and came back empty — and the gap between that and **Unverified** (the honest default when
  no query ran) is made explicit, which is the verdict-discipline gain.
- **Bounded scope, by design.** This binds only *queryable* metrics. Non-queryable claims — judgment,
  intent, "is this well-designed" — keep the existing refute-by-default treatment ([adversarial-review]);
  this ADR does not extend live-query duty to claims no primary source can resolve.
- **Honest enforcement gap.** Until the verify-before-refute workflow step ships, nothing mechanically
  stops a panel from skipping the query; the rule holds by reviewer discipline. Promote the wording from
  "convention" toward "toolable→enforced" only when (and if) that step lands.

## Affected obligations / constraints

- **Refines:** the adversarial-review discipline / panel verdicting ([ADR-0095](./0095-review-model-grounding.md))
  for the queryable-metric case, and reaffirms the deterministic-not-judge enforcement spine of
  [ADR-0063](./0063-honesty-framework-and-tooling-boundary.md) and [ADR-0043](./0043-checkable-documents.md).
- **Does NOT change:** refute-by-default for non-queryable claims, the verdict set, the artifact formats,
  or any check contract. This is a NEW ADR refining prior ones by reference (Nygard immutability) — it
  edits none of them in place.
