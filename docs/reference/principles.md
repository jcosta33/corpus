# Principles

_Advanced design note — internal rationale; not needed to use Corpus._

Corpus centers on clear requirements, bounded tasks, review evidence, and durable findings.
The wager behind all four: generation outpaces validation, so the validation side gets the structure. The
spec holds intended behavior; code holds implementation reality; the review packet and the
status board connect the two. Everything else in the framework exists to serve that loop —
and when two design choices collide, the principles below are the tiebreakers.

## No runtime in this repo

Corpus is markdown plus your agent. Nothing here parses, lints, schedules, or verifies anything.
Every description of tool behavior — a checker, a packet drafter, a drift recomputation — is a
**contract for tooling**, collected in [future CLI](future-cli.md), with corpus-cli as the
reference implementation in progress.

- **Consequence.** No page may claim a CLI is required or that automation already exists.
  "Corpus checks X" is always wrong; for a capability that has not shipped, "a future
  `corpus review` evidence-match can flag X" is the honest form.
- **Tiebreaker.** Tempted to say Corpus _does_ something? Ask whether this repository ships code
  that does it. It does not. Restate it as a contract a tool can build against.

## Conventions are self-policed, not machine-enforced

A markdown workflow cannot enforce anything, and pretending otherwise is the fastest way to
lose an engineer's trust. So every rule in these docs carries one of four honesty levels:

- **convention** — expected practice; nothing enforces it;
- **checklist** — review is expected to inspect it;
- **toolable** — a named optional tool can check it (e.g. corpus-cli's
  `corpus check`);
- **enforced** — a shipped tool actually enforces it. Today, nothing qualifies.

- **Consequence.** Enforcement-sounding wording — that something is rejected, gated, or failed
  automatically — never appears without a shipped tool behind it. Teams may adopt stricter
  policy ("we treat C003 as blocking") — that is the team enforcing, not Corpus. The legend and
  approved phrasings live in [checks](checks.md).
- **Tiebreaker.** When a property _must_ hold regardless of any model's cooperation, name the
  deterministic check outside the model — a CI step, a hook, a schema — and mark it toolable
  until that check exists.

## Code is implementation reality

Code and tests can **falsify** a requirement — a failing run is evidence the intent was not
met — but they never **silently amend** one. Intent lives in specs and decisions; reality lives
in code; neither overwrites the other without a recorded act.

- **Consequence.** When code and a requirement disagree, the result is Fail, Contradicted, or
  Stale, and the conflict routes to the three-way reconcile — re-run the verification, amend
  the requirement, or fix the code ([drift](drift.md)). Which intent governs when two artifacts
  disagree is [source authority](source-authority.md).
- **Tiebreaker.** If accepting a change would mean the spec now "means" whatever the code does,
  stop: that is an amendment, and amendments are authored, not inferred.

## Pasted evidence beats schema-valid output

A well-formed artifact is not a verified one. A tidy coverage table, a green exit code, a
confident "tests passed" — these are _shape_. Evidence is the pasted output or the CI link a
reader can inspect; unsupported done-claims are the failure this principle exists to catch,
illustrated (small-N, preliminary) by [[EVIBOUND]](../research/sources.md#EVIBOUND).

- **Consequence.** A Pass needs pasted output, a CI link, or, for a manual Verify method, a
  named human's recorded observation; an empty Evidence cell means Unverified, never Pass;
  reviewers spot-check at least one green row. These are checklist-level
  rules — review inspects them; nothing in this repo enforces them.
- **Tiebreaker.** When a claim rests on "it parsed" or "the build is green" with nothing
  pasted: demand the output.

## Provider neutrality

Corpus assumes nothing about which agent does the coding — Claude Code, Codex, Cursor, Aider, a
human. The artifacts are plain markdown any of them can read; the workflow survives a vendor
change without a rewrite.

- **Consequence.** No page hard-codes provider-specific behavior; agent capability claims are
  dated evidence, never load-bearing assumptions. One `AGENTS.md` serves every tool — peers
  like `CLAUDE.md` are symlinks to it, one bootloader for many agents.

## Citations are contextual, and facts have sources

Corpus holds its own docs to the standard it asks of agents. Every fact-shaped, load-bearing
claim cites a verified source inline — `[[KEY]]` resolving to
[the bibliography](../research/sources.md) — and the citation travels with the claim wherever
the text moves. A claim without a verified source is stated as **design rationale**, not fact.

- **Consequence.** Non-peer-reviewed sources are cited only as preliminary and never carry a
  hard rule; a rejected or unverifiable source is never cited; a new empirical claim first
  establishes its grounding. A fact-shaped sentence with no source and no "design rationale"
  label is a defect.
- **Tiebreaker.** Can't find the source? Then the sentence is an opinion — label it as one or
  cut it.

## Using these principles

1. **In a decision record.** Cite the principle that motivates the choice; a change to a
   principle is itself a decision, recorded in [`docs/adrs/`](../adrs/).
2. **In review.** Ask which principle a change serves and which it strains. The first four are
   absolute; nothing later in the docs may weaken them.
3. **As a skim test.** A page, template, or guide that contradicts a principle without
   explanation is a defect, not a style choice.

## Related

- [Source authority](source-authority.md) — which intent governs, and who approves changes.
- [Drift](drift.md) — the reconcile that keeps Pass honest over time.
- [Checks](checks.md) — the honesty legend applied rule by rule.
- [Design decisions](../adrs/README.md) — the recorded history behind these choices.
