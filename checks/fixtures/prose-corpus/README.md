# Writing-rules corpus

_Advanced design note — internal rationale; not needed to use Corpus._

The labeled fixture set for the writing-rules watchlist in
[the checks reference](../../../docs/reference/checks.md): short requirement-prose spans,
each paired with its ground-truth label — `clean`, or the specific `SOL-P` code from the
checks catalogue that should fire, with the reason. **Inert fixture data — nothing here
runs.** Corpus ships no detector; this corpus is what a detector — corpus-cli's
`corpus check`, or a human reviewer — is scored _against_.

## Why this corpus exists

Structural checks are deterministic — a requirement either has a `Verify with:` line or
it does not. The writing rules are different: they judge prose for vague quality words,
loopholes, bundling, and missing baselines, and any detector of them can mis-fire on
clean prose (a false positive) or miss a real problem (a false negative). Field studies
put lightweight requirement-smell detection well below perfect precision
[[SMELLS]](../../../docs/research/sources.md#SMELLS) — which is exactly why the watchlist
is advisory, and why a detector's accuracy is only measurable against ground truth. This
corpus is that ground truth: spans whose correct label is known independent of any
detector, so precision and recall can be computed by hand or by a harness.

## The accuracy baseline

Design targets for this curated set — chosen acceptance bars, not a measurement claimed
of any deployed detector. They sit deliberately above the field-measured ceiling
[[SMELLS]](../../../docs/research/sources.md#SMELLS), because a curated gold corpus is a
far more controlled setting than production prose.

| Metric    | Target | Meaning on this corpus                                                          |
| --------- | ------ | ------------------------------------------------------------------------------- |
| precision | ≥ 0.90 | of the spans a rule flags, at least 90% are true problems (few false positives) |
| recall    | ≥ 0.85 | of the true problems present here, at least 85% are flagged (few misses)        |

Two definitions make the tally well-formed:

- A **true positive** is a labeled-problem span (`label` ≠ `clean`) on which the detector
  fires the **same code** the label records.
- A **false positive** is any code fired on a `clean`-labeled span, or the wrong code
  fired on a problem span.

The `clean` items are not filler — they are the precision anchor. A detector that flags
a `clean` item is wrong even if it catches every problem, and only the `clean` items can
expose that. The set therefore pairs **near-miss twins**: a problem span and its clean
fix that differ only by the same-line observable criterion (the rule of thumb in
[the checks reference](../../../docs/reference/checks.md): a risky word is fine when the
same line makes it checkable).

## Annotator-agreement floor

When the detector is an LLM judge, single-judge scores are not internally reliable, so
the targets above are measured against this gold set — never asserted of a judge at
runtime. The labels are written to a Cohen's κ ≥ 0.6 inter-annotator-agreement floor:
each label is meant to be one a second independent reviewer would assign from the
`reason` field alone. Deterministic structural checks carry no such caveat — only the
heuristic writing rules do.

## How a checker or a human uses it

1. Take each item's `text` (the span under judgment) plus its `context` — binding versus
   commentary; the force of every writing rule depends on which.
2. Apply the writing rules (or a reviewer's judgment) to the span.
3. Compare what fired against the item's `label`:
   - `clean` → nothing should fire (any fire is a false positive);
   - a code → that exact code should fire (a different code, or silence, is a miss).
4. Tally true and false positives and the misses across the set; compute precision and
   recall; check them against the baseline above.

Because the label is recorded in data — not computed by the checker — the corpus catches
a detector that flags everything (precision collapses on the `clean` items) and one that
flags nothing (recall collapses on the problem items) as readily as one with a subtle
per-code bug.

## What is in this directory

| File                             | Holds                                                                    |
| -------------------------------- | ------------------------------------------------------------------------ |
| `README.md`                      | this contract — what the corpus is, the baseline, how it is used         |
| [`labeled.yaml`](./labeled.yaml) | the labeled items: span, context, label, expected code, severity, reason |

The corpus is self-contained: every label is decidable from the item's own `text`,
`context`, and `reason`. The word families and the same-line rule the labels invoke are
the writing rules of [the checks reference](../../../docs/reference/checks.md); this
corpus pins expected outcomes, not rule mechanics.
