---
name: sus-research
description: Research a decision until evidence can carry it. Use when comparing options, evaluating APIs or products, sizing markets, mapping competitors, studying customers, synthesizing reviews, inspecting UX, or testing positioning. Do not use as the owner of settled fact-checking, present-state audits, or intent authoring.
---

# Sus Research

One question. Fit evidence. Zero counterfeit certainty.

Ask required questions through the native picker, or numbered choices plus `Other`. Put the
recommendation first; offer three genuine options, two if binary; give each one plain reason and
cost.

## Method

Lock the decision, audience or segment, scope, time horizon, and reversal evidence. Map options and
counter-evidence before chasing the first attractive answer.

Force material ambiguity in scope into explicit human selection. Block dependent research until
selection.

### Evidence

Match source competence to each claim:

- standards and specifications for defined contracts;
- current official docs and versioned source for APIs;
- safe direct exercise for current product behavior;
- inspectable studies or benchmarks for comparative and outcome claims;
- contemporaneous first-party records for announcements and intent;
- disclosed user research for user experience; and
- secondary analysis for its own analysis or as a route to primary evidence.

For empirical, scientific, safety, reliability, performance, prevalence, or causal claims, match
the claim to direct evidence:

| Claim | Strong evidence | Common mismatch |
| --- | --- | --- |
| Standard or contract | Current specification | Tutorial paraphrase |
| API support | Versioned docs, source, executable contract | Another version's review |
| Product behavior | Safe recorded exercise | Marketing copy |
| Comparative performance | Representative matched benchmark with method, data, and variance | Undisclosed vendor workload |
| Causal effect | Design controlling alternatives with uncertainty | Before/after correlation |
| Prevalence | Disclosed sampling frame and denominator | Collected examples |
| Actor intent | Contemporaneous first-party record | Later inference |
| User experience | Appropriately sampled disclosed research | One anecdote |

For every load-bearing source, record provenance, date, version, funding, conflicts, design,
comparison groups, population, setting, outcome definition, measurement, baselines, available raw
data, sample size, variance, missing data, sensitivity, replication, contradiction, and whether the
source reports observation or inference. Downgrade confounding, selective reporting, indirectness,
staleness, imprecision, undisclosed methods, conflicts, and unresolved contradiction. Upgrade only
for stronger design or independent replication. Record the reason.

For market, customer, competitor, UX, category, positioning, pricing, review, market-sizing, or
synthetic-respondent work, fix the segment, geography, horizon, and reversal evidence. Classify each
source as observed behavior, user evidence, primary research, official market data, secondary
analysis, or synthetic output. Use it only inside that competence: pricing proves price, marketing
proves positioning, and sampled reviews prove only sampled experience.

Claims such as `most`, `common`, `standard`, or `users expect` require the searched population,
known denominator, independent instances, and contrary cases. Sparse evidence supports only an
observed example or candidate pattern. No witness count converts a sample into a market fact.

Verify competitor behavior against current product use, docs, changelogs, pricing, API references,
app listings, or dated screenshots. Record URL, access date, account, region, version, and exact
observation. For surveys and interviews, disclose sponsor, population, recruitment, dates, mode,
screener, stimulus, geography, segment, incentives, weighting, cleaning, response limits, and bias.
For reviews, disclose collection, dates, platforms, sampling, duplicates, bots, incentives,
moderation, language filters, and missing populations. Keep quotations short and traceable.

Synthetic respondents may generate hypotheses, pilot stimuli, or augment a model calibrated against
real data. They are not customers and cannot prove demand or willingness to pay. Label them and name
the real-data check. Market sizing must show formulas, units, dated sources, segment boundaries,
assumptions, sensitivity, and separate TAM, SAM, and SOM.

Rate confidence `High` only for direct, recent, segment-matched, independently triangulated
evidence; `Moderate` for direct but partial or mixed triangulation; `Low` for indirect, stale,
small-sample, single-source, marketing, or synthetic evidence; and `Very low` for assumption-heavy
direction. Name every downgrade and surface disconfirmation.

Exercise current behavior when lawful, safe, and affordable. State every access boundary. Mark
unreachable or unsupported claims `[unconfirmed]`.

When exercising a product, record version, account, region, flags, date, action, expected observable,
and untouched output. Stop when terms, cost, safety, or private data make exercise improper. Record a
rejected source only when another researcher could reasonably reuse it; name the exact defect such
as wrong identity, retraction, unavailable method, superseded version, population mismatch,
fabricated citation, or unresolved conflict. Never reject by venue alone.

## Artifact

Resolve `~/.agents/artifacts/<workspace>/` to an absolute path; derive `<workspace>` from the
repository or working-directory basename. Write there with `type: research`, a unique `RESEARCH-`
ID, and linked sidecars beside it. On collision or ambiguous workspace, present human-readable name
choices. On a blocked write, offer grant and retry, another agent-neutral user directory, or cancel.
Never overwrite or fall back to a repository, vendor directory, or temporary path.

Write local source references relative to the artifact. Use absolute paths only for runtime handoff.

Start with:

```yaml
---
type: research
id: RESEARCH-{{slug}}
---
```

### Shape

Use only sections carrying payload:

- **Question and scope**
- **Method and coverage**
- **Findings**
- **Options comparison**
- **Open questions**
- **Advisory recommendation**

Give each finding stable `R-NNN`, one claim, exact evidence, confidence, and decision relevance.
Separate observation, source claim, inference, and recommendation. Put comparable options in a
table with named criteria. Preserve disconfirming evidence and material rejected sources.

Tie the recommendation to finding IDs. When evidence cannot support direction, name the exact
question or test that unlocks it. Keep intent and requirements human-owned.

## Output

Before handoff, cut repetition, softness, ceremony, and structural bloat without changing contracts,
identifiers, verbatim source text, evidence, or behavior. Rerun applicable checks. Return only
clickable Markdown links for the research artifact and every sidecar, with compact `~/.agents/...`
labels and fully expanded absolute destinations. Explain only a blocker, failed creation, incomplete
verification, or irreversible-action confirmation.

## Close

Once fully actioned and no downstream step needs it, require one human disposition for the artifact
and its sidecars: Delete, Leave, or Promote. Promote moves transient material into project-owned
permanence. Delete every selected path and verify absence; survivors block close.
