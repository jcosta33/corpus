---
name: corpus-research
description: Research a decision until evidence can carry it. Use when comparing options, evaluating APIs, libraries, or products, sizing markets, mapping competitors, studying customers or reviews, inspecting UX, or testing positioning. Do not use for checking one settled claim, assessing present code, or writing requirements.
---

# Corpus Research

One question. Fit evidence. No counterfeit certainty.

## Method

Lock the decision, segment, scope, horizon, and the evidence that would reverse the answer. Map the
options and the counter-evidence before chasing the first attractive answer. Ask the human only when
scope is materially ambiguous: recommendation first, two or three real options, each with its cost.

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
conflicts of interest, and whether it reports observation or inference. Downgrade for confounding,
selective reporting, indirectness, staleness, imprecision, undisclosed method, or unresolved
contradiction. Upgrade only for a stronger design or independent replication. Say why.

For market, customer, and competitor work, fix the segment, geography, and horizon. Pricing proves
price, marketing proves positioning, and sampled reviews prove only sampled experience. Claims such
as `most`, `common`, or `users expect` need a searched population, a denominator, and contrary
cases. Synthetic respondents generate hypotheses only; label them and name the real-data check. A
market size shows formulas, units, dated sources, assumptions, sensitivity, and separate TAM, SAM,
and SOM.

Exercise current product behavior when that is lawful, safe, and affordable. Record version,
account, region, date, action, and untouched output. Mark unreachable claims `[unconfirmed]`. Reject
a source only for a named defect, never by venue alone.

Rate confidence:

- `High`: direct, recent, segment-matched, and independently triangulated.
- `Moderate`: direct but partial.
- `Low`: indirect, stale, small-sample, single-source, marketing, or synthetic.
- `Very low`: assumption-heavy.

Name every downgrade.

## Shape

```yaml
---
type: research
id: RESEARCH-{{slug}}
---
```

Use only the sections that carry payload: Question and scope, Method and coverage, Findings,
Options, Open questions, and Recommendation.

Give each finding a stable `R-NNN`, one claim, its exact evidence, a confidence, and its decision
relevance. Keep observation, source claim, inference, and recommendation separate. Tie the
recommendation to finding IDs. When the evidence cannot support a direction, name the test that
would. The decision stays human.

## Artifact

Write `~/.agents/artifacts/<workspace>/<ID>.md` with `~` expanded. `<workspace>` is the repository
or working-directory basename. Put sidecars, such as evidence receipts and run notes, beside it and
link them. Never overwrite; on a collision, ask for a name. If the directory is unwritable, offer
grant and retry, another user directory, or cancel. Never fall back to the repository, a vendor
directory, or a temporary path. Write local source references relative to the artifact; hand off
absolute paths.

## Output

Return only clickable links to the artifact and its sidecars, labelled `~/.agents/...`, with
absolute destinations. Explain only a blocker, a failed write, incomplete verification, or an
irreversible-action confirmation.

## Close

When no downstream step needs the set, ask the human once: Delete, Leave, or Promote into
project-owned records. After Delete, confirm every path is gone; a survivor blocks close.
