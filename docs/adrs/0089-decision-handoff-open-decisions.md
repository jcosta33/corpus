---
type: adr
id: adr-0089
status: accepted
created: 2026-06-20
updated: 2026-06-20
---

# ADR-0089 — The decision handoff: an `## Open decisions` section that frames an open decision for the human (convention, fact-not-verdict, evidence-grounded)

## Context

A developer adopting Corpus rarely runs one agent — they orchestrate several, each deep in its own
domain (a parser change here, a docs sweep there, a benchmark in a third worktree). At the moment a
unit of work closes and a decision is owed, that developer is **context-poor**: pulled across domains,
holding none of any single agent's depth. The agent that just did the work is the only party still
holding the full context. A closeout that ends in three terse bullets ("next: do X / consider Y /
maybe Z") forces the developer to re-derive context the agent already has — and re-contextualizing the
decision is the agent's job, not the developer's. (This is the owner's stated working preference, raised
2026-06-20.)

A `/deep-research` run (2026-06-20) and a follow-up 2026 recency check grounded the question in primary
sources. The findings, in short:

- A lone recommendation has documented failure modes in **both** directions: **over-trust** of the
  recommendation [[OVERRELIANCE-REVIEW]](../research/sources.md#OVERRELIANCE-REVIEW)
  [[AICODE-INSECURE]](../research/sources.md#AICODE-INSECURE), and, once the agent errs even once,
  **algorithm aversion** — the human over-discounts it thereafter
  [[ALGOAVERSION]](../research/sources.md#ALGOAVERSION).
- **More justification does not fix this** and can worsen it: explanations often persuade rather than
  help a person evaluate [[OVERRELIANCE-REVIEW]](../research/sources.md#OVERRELIANCE-REVIEW); a _light
  cognitive forcing function_ reduces over-reliance better than explanation alone
  [[OVERTRUST-CFF]](../research/sources.md#OVERTRUST-CFF). The job of the "why" is to make checking
  cheap, not to convince.
- **Choice overload is not a law of option count** — count alone has a near-zero average effect; harm
  is conditional on decision _difficulty_ and set complexity
  [[CHOICEOVERLOAD]](../research/sources.md#CHOICEOVERLOAD). So the lever is _comparable, well-structured
  options_, not a hard cap on how many.
- The "present evidence for and against the options, not a single recommendation" stance comes from a
  position paper [[EVALAI]](../research/sources.md#EVALAI) and is **contested** — a reasoned design
  stance, not a proven result. The 2026 recency check
  [[PERSUASIONPARADOX]](../research/sources.md#PERSUASIONPARADOX) is **mixed and task-dependent** —
  explanations hurt on visual reasoning but _helped_ on language-based logical reasoning (the task class
  closer to a developer's decision) — so it corroborates only weakly and is cited as preliminary, never
  load-bearing.

The review packet already **routes exceptions to human attention** (ADR-0060): unverified rows, scope
drift, risky files. But an _open decision_ is not an exception in the work — it is a fork the human
must choose. The packet has no home for it: `## Suggested decision` is the reviewer's merge call only.
This ADR adds that home.

## Decision

1. **Adopt the decision handoff as a convention.** When a unit of work closes with a genuinely open
   decision the human must make, the closeout **frames** that decision rather than dumping bullets. The
   concrete home is an optional **`## Open decisions`** section in the review packet (extending
   ADR-0060's section list — the ADR-0076 precedent, which added the optional `Task status` section to
   that same list); the same convention applies to a task's
   `## Run summary` and to an agent's chat handoff. _Level: convention (ADR-0063) — nothing enforces it;
   review may inspect it._ It **routes a decision to the human — a fact, never a verdict** (ADR-0077
   Decision 8): the section presents and recommends; the human decides.

2. **The fields are fixed; the content is present only when a decision is open.** Each open decision
   carries: **the decision** (one line) · **2–4 comparable options**, each with its tradeoff (the case
   **for _and_ against**) · **a recommendation + a brief why** · **the context/impact** the agent holds
   and the human may not · **what it blocks**. The for-and-against framing guards both failure modes —
   over-trust [[OVERRELIANCE-REVIEW]](../research/sources.md#OVERRELIANCE-REVIEW) and algorithm aversion
   [[ALGOAVERSION]](../research/sources.md#ALGOAVERSION) — by giving the human something to re-engage
   with rather than reflexively accept or reject.

3. **Present only when something is open; no counts ceremony.** When nothing is open, the section is
   **absent** — that is the default and there is no ritual to perform. Options are _listed_, never
   tallied; the 2–4 range is a soft heuristic, not a hard cap, because the lever is decision difficulty,
   not option count [[CHOICEOVERLOAD]](../research/sources.md#CHOICEOVERLOAD). This keeps the convention
   low-ceremony — consistent with the no-counts-ceremony rule.

4. **Short calibration cues over persuasion; the recommendation is skippable.** The "why" is brief and
   verification-oriented — _how sure · what would change it · what it blocks_ — not a persuasive essay,
   because explanation alone does not cure over-trust and longer explanation can worsen it
   [[OVERTRUST-CFF]](../research/sources.md#OVERTRUST-CFF)
   [[OVERRELIANCE-REVIEW]](../research/sources.md#OVERRELIANCE-REVIEW)
   [[PERSUASIONPARADOX]](../research/sources.md#PERSUASIONPARADOX). "What it blocks" is a lightweight,
   forcing-function-_inspired_ cue — but honestly, a static markdown section **cannot** implement an
   interaction-level cognitive forcing function (the [[OVERTRUST-CFF]](../research/sources.md#OVERTRUST-CFF)
   mechanisms — decide-before-seeing, withhold-until-requested, a brief wait — need a live interaction).
   So the over-trust mitigation here rests on the **for-and-against framing** (itself contested,
   Decision 6), not on a true CFF. The recommendation is **present-but-ignorable** — the human may skip
   it — **never a forced second opinion**, which would trade over-trust for under-trust; a genuine
   decide-before-seeing interaction is available only in the chat-handoff channel, not the persisted packet.

5. **A convention this cycle — no check, no contract mint.** `## Open decisions` is prose; it surfaces a
   decision for a human, with no closed-value form a checker could reconcile (unlike C012–C015). So this
   ships as a convention only — no `checks.yaml` row, no contract-version bump — matching ADR-0088's
   convention-first posture. Any future check (e.g. "a closed task left an undocumented owner-decision")
   is deferred to a measured ADR, and would risk the over-reliance an always-on prompt induces.

6. **Recorded honestly as a well-reasoned convention, not a proven win.** The options-over-recommendation
   prescription rests substantially on a **contested position paper**
   [[EVALAI]](../research/sources.md#EVALAI) and on adjacent human-AI-decision evidence, not on a
   measured study of agent-orchestration handoffs; interventions of this family **reduce over-reliance
   but do not reliably produce _appropriate_ reliance**
   [[RELYORNOT]](../research/sources.md#RELYORNOT). The 2026 recency check strengthens the underlying
   over-reliance findings and adds **developer-domain** support
   [[AICODE-INSECURE]](../research/sources.md#AICODE-INSECURE) — but the convention is adopted as a
   reasoned design stance, revisitable if measured evidence in the orchestration setting lands.

## Alternatives considered

| Alternative                                                 | Why weaker                                                                                                                                                                                                                                                                                                            |
| ----------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **End with a terse single recommendation (the status quo)** | A lone recommendation invites over-trust [[OVERRELIANCE-REVIEW]](../research/sources.md#OVERRELIANCE-REVIEW) and is brittle to one error → algorithm aversion [[ALGOAVERSION]](../research/sources.md#ALGOAVERSION); it also forces the context-poor orchestrator to re-derive the fork the agent already understood. |
| **A required, always-present `## Open decisions` section**  | An always-on second opinion induces over-reliance and trades over-trust for under-trust; present-only-when-open keeps it a signal, not boilerplate.                                                                                                                                                                   |
| **A hard option-count cap (e.g. "exactly 3")**              | Unsupported — option count alone has a near-zero average effect; the lever is decision difficulty and option comparability [[CHOICEOVERLOAD]](../research/sources.md#CHOICEOVERLOAD). Hence a soft 2–4, not a rule.                                                                                                   |
| **Long, persuasive justification prose**                    | Explanation alone does not cure over-trust and detailed explanation can worsen it [[OVERTRUST-CFF]](../research/sources.md#OVERTRUST-CFF) [[OVERRELIANCE-REVIEW]](../research/sources.md#OVERRELIANCE-REVIEW); the "why" should make checking cheap, so short calibration cues win.                                   |
| **Mint a check / contract rule now**                        | No closed-value form to reconcile; premature for a prose convention, and an always-on prompt risks the very over-reliance the evidence warns of. Convention-first (ADR-0088 precedent); a check defers to a measured ADR.                                                                                             |

## Consequences

Accepted: the review packet gains an **optional** `## Open decisions` section; `docs/reference/artifact-formats.md`
and the kit's `templates/review.md` carry it; this **extends ADR-0060's** frozen review-packet section
list (the ADR-0076 precedent — which added the optional `Task status` section the same way; the original
set is not rewritten). It is **convention-level**:
nothing is enforced, no check fires, no contract version moves. Honors ADR-0077 Decision 8 (a fact, never
a verdict) and ADR-0063 (convention, never enforcement-claimed). Because the prescription rests on a
contested position paper and adjacent evidence rather than a measured orchestration study, it is recorded
as a **reasoned convention** — to be revisited if the benchmark or field evidence ever measures it.
Generalizes the owner's "frame the decision" preference into a framework affordance, so every adopter's
agents close a unit of work the same way.

## Propagation

`docs/reference/artifact-formats.md` (the `## Open decisions` entry in the review section list + a
load-bearing bullet) · `../corpus-starter-kit/templates/review.md` (the optional section with authoring
guidance) · `docs/research/sources.md` (the eight evidence entries, tiered) ·
`docs/adrs/README.md` (the index row) · the corpus-hq trail (SPEC/TASK/REVIEW + the persisted research).
Extends [0060](./0060-corpus-workspace.md); honors [0077](./0077-corpus-cli-reconcile-only-harness.md)
Decision 8 and [0063](./0063-honesty-framework-and-tooling-boundary.md); convention-first like
[0088](./0088-delegation-provenance.md). No contract change, no check.
