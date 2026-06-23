# Drift and staleness

_Advanced design note — internal rationale; not needed to use Corpus._

A **Pass is a statement about a moment**: the requirement said X, the code did Y, and the
evidence showed Y satisfies X — _then_. The moment the requirement text or the code changes,
that confirmation may no longer hold. Drift is the divergence between a requirement and its
implementation after a recorded Pass; staleness is drift made detectable. A green build is
shape, not truth — the question is whether the evidence still matches reality, not whether the
suite still exits zero [[EVIBOUND]](../research/sources.md#EVIBOUND).

## What a Pass would record

For drift to be detectable later, a Pass needs to pin what it actually looked at:

- a hash of the **requirement text** as judged,
- a hash of each **file the verification exercised** — both the files the change wrote and the
  files the verification read through, each flagged exercised or merely declared,
- the **verify command** the evidence came from.

**Honesty first:** these hashes are tool-emitted placeholders today — nothing in this repo
computes one. This is a toolable contract: `corpus status` ships today (it prints the derived
board), but recomputing staleness from recorded hashes to mark the board's `stale?` column is a
future capability. Until then the working
rule is simpler: when the spec or the touched code has changed since the review, re-run the
verify command before trusting the old Pass.

## The four stale triggers

A prior Pass becomes **Stale** when any of these holds:

1. **The requirement text changed.** Intent moved; the evidence confirmed wording that no
   longer exists.
2. **An exercised write surface changed.** A file the change wrote _and the verification
   actually exercised_ was edited after the Pass.
3. **An exercised read surface changed.** A dependency the verification read through was
   edited — read-side drift is just as real as write-side.
4. **The verify command was rebound.** The command behind the evidence was retargeted,
   replaced, or removed; the proof itself moved under unchanged code.

A Stale Pass reads as not-Pass until reconciled — checklist level: the reviewer treats it so;
nothing in this repo recomputes it. Only a Pass can go stale: a Fail, Blocked, or Unverified
was never trusted, so there is nothing to revoke. In a review packet a stale row looks like:

| ID     | Result       | Evidence                                                       | Human attention |
| ------ | ------------ | -------------------------------------------------------------- | --------------- |
| AC-001 | Pass (Stale) | output of 2026-05-20 predates a change to `src/auth/client.ts` | yes             |

## The participation rule

Which file edits count is decided by the **evidence path** — what the verification actually
exercised, not what was merely declared:

- A file the last Pass **exercised** participates, whatever kind of file it is. An in-place
  behavioral edit to a shared file the verification ran through must go Stale.
- A file the last Pass did **not** exercise does not participate on its own. A lockfile bump or
  an unrelated CI-matrix edit must not mark every requirement in the repo Stale.

Freshness follows evidence: drift on an exercised file always fires, drift on an unexercised
file never does by itself, and a requirement-text change fires regardless of any file.

A worked contrast: a tool that bumps a lockfile no verification exercised changes nothing — no
Pass goes stale. An in-place edit to a CI step that one requirement's verification _did_ run
through makes exactly that requirement's Pass stale, and no other.

## The three-way reconcile

A Stale result forces one of exactly three recorded resolutions — never a silent re-bless:

| Resolution                  | When                                                   | Effect                                                                                        |
| --------------------------- | ------------------------------------------------------ | --------------------------------------------------------------------------------------------- |
| **Re-run the verification** | The change is compatible; intent and code still agree. | A fresh Pass with fresh evidence replaces the stale one.                                      |
| **Amend the requirement**   | Intent changed; the code is the new desired behavior.  | The spec is amended by its owner ([source authority](source-authority.md)), then re-verified. |
| **Fix the code**            | Intent stands; the code drifted away from it.          | The code is corrected, then re-verified.                                                      |

Code can falsify a requirement — that is resolutions two and three — but it never silently
amends one. And resolution one means a genuine re-run: re-stamping a recorded hash without
re-running the command manufactures a false Pass.

The share of requirements whose latest result is Stale is a useful board-level signal: when it
climbs, verification has fallen behind change velocity. Tracking it is a convention — by hand
on the status board today.

## The honest scope limit

This rule detects **declared drift only**: changes reachable through the requirement text, a
file on the recorded evidence path, or the recorded command. It cannot see behavioral drift
through an undeclared dependency, a hidden global, or an environmental input nobody recorded —
what is unhashed is unseen. Closing that residual gap means observing behavior at runtime,
which has no home in a markdown-only workflow. A requirement whose true read set exceeds what
its verification exercises is a gap for review to catch, not a guarantee this page makes.

## Related

- [Source authority](source-authority.md) — why amendment is an authoring act, never an inference.
- [Reviewing output](../08-reviewing-output.md) — where a Stale row routes to human attention.
- [Future CLI](future-cli.md) — the contract a drift-recomputing tool builds against.
