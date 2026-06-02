# Skill (documentation): `empirical-proof`

> **For agents:** instructions → [`/scaffold/.agents/skills/empirical-proof/SKILL.md`](../../scaffold/.agents/skills/empirical-proof/SKILL.md)

---

## TL;DR

Confidence is free — models supply it gratis. Paste-or-stop turns **verification** into a side-channel that resists hallucinated summaries: the agent cannot complete the "successful task" pattern without first pasting the evidence the pattern is true. The skill self-activates on any task that writes code, runs validations or benchmarks, or makes verifiable behavioural claims; it skips only tasks with genuinely no verifiable claims (rare — surface as a blocker if you suspect it).

## What the skill actually enforces

Every claim in `## Self-review` gets its own **verbatim pasted command output** in a fenced block — no paraphrase, no "✅ all passing", no bundling multiple checks into one "all good". The last two lines (the runner's summary plus timing/exit) are the load-bearing part. Verifications go stale the instant the code changes, so the rule is **re-run after every change and re-paste** — especially during refactor and migration where the every-N-files validation fires repeatedly. When reviewing, the agent runs the validators **itself, in its own worktree**, with the worker's branch checked out; the worker's paste does not satisfy the gate.

## Why proof is framed as infrastructure, not culture

Announcing "agents should test" fails silently. Embedding proof slots in the templates and the SKILL body makes omission **mechanically conspicuous** — an empty paste block is visible where a free-text ✅ is not. It is still gameable with fabricated output, but fabrication is harder and more deliberate than echoing a confident summary.

## The submission contract

Evidence must be:

- **local** — taken after the last mutation batch; staleness dominates CI-only trust.
- **non-paraphrased** — the hash of a summary sentence is not the hash of stdout.
- **separated per claim** — bundling hides partial truth (the build passed, but did the tests?).

Reviews add **runner independence**: the verifier re-runs the worker's commands in the reviewer's worktree, so trust cannot be laundered through the worker's paste.

## Why last-line extracts

Full logs blow the context budget; extreme verbosity invites truncation mistakes. The gate asks for tails and summaries deliberately — enough entropy to falsify naive echoing while staying bounded. The known trade-off is sabotage via selective tail-paste; that is mitigated by review independence and, where an organisation wants it, a stricter overlay that widens the required window.

## Command resolution

The skill never invents commands. It resolves the project's validate/test commands by name through the consuming repo's `AGENTS.md > Commands` (with an optional architectural dep-validation command outside the standard contract — ask the user whether the project uses one). If `AGENTS.md` is missing or an entry is undefined, the skill **asks the user which command to run** before pasting any "verification output" rather than guessing.

## When *not* to relax the verbatim rule

Operational-outage environments still block silent success: when the toolchain is genuinely unavailable, escalate via `## Blockers` documenting the missing tool — never fabricate a green.

## Distinct from personas

Personas supply *which* proofs matter for a kind of work — a benchmark delta for performance-surgery, an assertion-flip for testing. `empirical-proof` supplies the *submission contract* uniformly across all of them.

## Bundled resources

- `references/evasions.md` — the full catalogue of common evasions and their responses. The SKILL body keeps the top three inline ("I ran it earlier", "obvious from the diff", "CI will catch it"); pull up the reference when a different evasion surfaces.

## Related

- [Empirical proof concept](../concepts/09-empirical-proof.md)
- [ADR 0008: empirical proof as framework primitive](../adrs/0008-empirical-proof-as-framework-primitive.md)
- [Verification gates reference](../reference/verification-gates.md)
- [Adversarial-review skill](adversarial-review.md) — the review-side rerun discipline
