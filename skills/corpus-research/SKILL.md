---
name: corpus-research
description: Research a decision until evidence can carry it. Use when comparing options, evaluating APIs, libraries, products, or licenses, or establishing how a standard, platform, or product behaves. Do not use for checking one settled claim, assessing present code, or writing requirements.
---

# Corpus Research

One question. Fit evidence. No counterfeit certainty.

## Method

Lock the decision, scope, horizon, and the evidence that would reverse the answer. Map the options
and the counter-evidence before chasing the first attractive answer. Ask the human only when scope
is materially ambiguous.

Match each claim to a competent source:

| Claim | Strong evidence | Common mismatch |
| --- | --- | --- |
| Standard or contract | Current specification | Tutorial paraphrase |
| API support | Versioned docs, source, executable contract | Another version's review |
| Product behavior | Safe recorded exercise | Marketing copy |
| Comparative performance | Matched benchmark with method, data, and variance | Undisclosed vendor workload |
| Causal effect | Design controlling alternatives, with uncertainty | Before/after correlation |
| Prevalence | Disclosed sampling frame and denominator | Collected examples |
| Actor intent | Contemporaneous first-party record | Later inference |
| User experience | Sampled, disclosed research | One anecdote |

For every load-bearing source, record provenance, date, version, method, population, sample size,
conflicts of interest, and whether it reports observation or inference. Quote the passage that
supports each load-bearing claim; a link that resolves is not support. Search only as wide as the
decision needs; more sources do not repair weak ones.

Give each claim one outcome, and name what weakens it, such as confounding, staleness, indirectness,
small samples, undisclosed method, or vendor interest:

- `Verified`: a competent source's passage directly supports it; a load-bearing claim also needs an
  independent source, meaning a different publisher with different underlying data.
- `Disputed`: competent sources disagree. Show each figure with its source; never average them.
- `Unverified`: no competent source was reached. Name the check that would settle it.
- `Overturned`: the weight of evidence contradicts it.

Exercise current product behavior when that is lawful, safe, and affordable. Record version,
account, region, date, action, and untouched output. Reject a source only for a named defect, never
by venue alone.

## Shape

```yaml
---
type: research
id: RESEARCH-{{slug}}
---
```

Use only the sections that carry payload: Question and scope, Method and coverage, Findings,
Options, Open questions, and Recommendation.

Give each finding a stable `R-NNN`, one claim, its exact evidence and supporting passage, its
outcome, and its decision relevance. Keep observation, source claim, inference, and recommendation
separate. Tie the recommendation to finding IDs. When the evidence cannot support a direction, name
the test that would. The decision stays human.

## Artifact

Write `~/.agents/artifacts/<workspace>/<ID>.md` with `~` expanded; `<workspace>` is the repository
or working-directory basename. Keep sidecars, such as evidence receipts and run notes, beside it and
link them. On a collision or an unwritable directory, ask the human; never overwrite, and never fall
back to the repository, a vendor directory, or a temporary path. Write local references relative to
the artifact. Return only clickable `~/.agents/...` links with absolute destinations, and explain
only a blocker, a failed write, incomplete verification, or an irreversible-action confirmation.

## Close

When no downstream step needs the set, ask the human once: Delete, Leave, or Promote into
project-owned records. After Delete, confirm every path is gone; a survivor blocks close.
