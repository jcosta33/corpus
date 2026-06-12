---
name: empirical-proof
type: agent-guide
description: >-
  Bind every completion claim to real evidence: run the command, paste the
  verbatim output (command, exit, summary) next to the claim. ALWAYS apply when
  recording a Pass or Fail against a requirement or check, when asserting how
  anything behaves, or when judging someone else's "done". Reject a bare "tests
  passed", schema-valid output, a paraphrase, a stale pre-edit run, or a
  reviewer trusting the worker's paste. Skip when authoring a document that
  makes no behavioural claim and runs nothing.
---

# Empirical proof — evidence or it didn't happen

A model is a pattern-completer: the pattern of a finished task includes confident language ("all
tests pass", "looks correct") regardless of whether the claim is true. The structural defence is
forced visible output — no claim is recorded as Pass without the real, re-runnable output pasted
beside it. In the kit this discipline lives inside the three core guides; this standalone copy is
the form used for working on this repo, where the runs are mostly greps, link checks, and diff
reads. The rule is identical, and it is checklist level throughout: review inspects it; nothing
in this repo enforces it.

## The rule

For every claim with a verification method — a requirement's `Verify with:` line, a checklist
item, a "this resolves now" assertion — resolve it to a real command, run it against the current
state of the work, and paste the verbatim output (command, exit condition, summary lines) into
the record next to the claim. **No paste, no Pass.** Commands resolve from the workspace
`AGENTS.md` Commands table; if the command you need is missing there, ask — never guess, because
a guessed command proves nothing about the real project. In this repo the table is empty by
design: the command _is_ the grep or link check itself, pasted with its output.

## What separates a real proof from a plausible one

- **The exact bytes of the run.** Output pasted as data in a fenced block: no quoting, no
  annotation injected mid-paste, no truncation that hides the summary.
- **One paste per claim.** Each claim binds to its own run. An "all good" bundle hides which
  check actually ran — and which never did.
- **Freshness.** A proof pasted before a later edit is stale and no longer backs the claim.
  Edit anything, re-run, re-paste.

## Output shape

Good — verbatim, fenced, with the resolved command, exit, and summary:

````markdown
AC-001: Pass

```
$ grep -rn "swarm_language" docs/
(no matches) — exit 1
```
````

Bad — paraphrased ("all greps clean", "everything passes"). Plausible, possibly even true — and
unverifiable from the document, so it records as Unverified.

## Refuses — never a Pass

- **Schema-valid or well-formed output.** Shape is not truth; a claim whose only evidence is
  "the output matched the expected shape" is Unverified.
- **"Tests passed" with no command, exit, or output.** The bare phrase is Unverified — the
  `non-empty-paste` evidence rule (checklist level; `docs/reference/checks.md`).
- **A prediction.** "Should pass", "expected to work", "obvious from the diff" — none is a
  recorded run. A diff runs nothing.
- **A judgment call with no recorded reasoning.** A by-hand Pass names who judged and what they
  examined, or it is Unverified — and the person who wrote the change never judges it.
- **A reviewer trusting the worker's paste.** An upstream paste shows the command ran at some
  past moment, not that it passes now. Re-run it yourself before recording the result.
- **An environmental failure rounded up.** A check that could not run is Blocked — truth unknown
  — never Pass. If you cannot tell whether it ran at all, record Unverified: the weaker, more
  honest claim.

## Common evasions

| Evasion                                          | Response                                                       |
| ------------------------------------------------ | -------------------------------------------------------------- |
| "I already ran it earlier in the session."       | Re-run after every change; the earlier run is stale.           |
| "It's obvious from the diff."                    | A diff runs nothing. Run the check; paste the output.          |
| "Schema validated, so it's correct."             | Shape is not truth.                                            |
| "CI will catch it."                              | The discipline is this session's gate, not CI's.               |
| "The output is too long to paste."               | Paste the command and the summary lines, not the whole log.    |
| "Pasting is ceremony; I reviewed in good faith." | Trust is the vulnerability this rule removes; run it yourself. |
| "It failed for unrelated environmental reasons." | That is Blocked, surfaced as a blocker — never a silent Pass.  |

The full catalogue: `references/evasions.md` — pull it up when one surfaces.

## Self-review delta

When this discipline is active, additionally confirm before declaring done:

- Every completion claim maps to a pasted, re-runnable run — none rests on say-so.
- One paste per claim; nothing bundled; no claim left without a result.
- No pasted output predates a later edit.
- In a review, you re-ran the checks yourself rather than trusting the worker's paste.
- Every Blocked or Unverified is recorded as such, not rounded up to Pass, and any missing
  command was asked for, never guessed.
