---
type: adr
id: 0030-unified-artifact-set
status: accepted
created: 2026-06-02
updated: 2026-06-02
supersedes:
superseded_by:
---

# ADR-0030: The unified artifact set

## Context

The pre-kernel model defined four core document types — research, spec, audit, bug-report — with extended types orbiting them (ADR 0001). That set named the *upstream sources of truth* well, but it had no place for the artifacts the rest of the pipeline depends on: there was no first-class **trace** carrying implementation claims against obligation IDs, no **finding** as the unit of durable evidence, no **memory** recall layer, and no home for a **verdict** (the judged outcome of a review). Without these, completion claims, drift, and durable knowledge had nowhere structured to live, and a verdict risked being modelled as a standalone file. The recast in §29 records the decision to close these gaps while keeping every source document's epistemic stance intact.

## Decision

The kernel defines **one unified artifact set** centred on the obligation graph (§20, §29). It comprises the seven Tier-1 pipeline-core artifacts — `spec.swarm.md`, `task.md`, `trace.md`, `review.md`, `finding.md`, `adr.md`, `memory/INDEX.md` — plus the Tier-3 stdlib source-doc templates (`audit.md`, `research.md`, `bug-report.md`, and the conditional `prd.md`/`rfc.md`). It **adds the four artifacts the four-document model lacked**: the **trace**, the **VERDICT** (a SOL *block* that lives inside `review.md` — there is no `verdict.md`, §20.2.3), the **finding**, and **memory** (§29.3). Each source document **preserves its epistemic stance** on promotion: observation, diagnosis, inquiry, intent, and proposal remain non-authoritative until an `author` pass turns them into spec obligations, exactly as the §29.1 stance table fixes. The full set, contracts, and templates are specified in §20–§21; the recast that maps the earlier four onto it is §29.

A conformant repository MUST ship the contract and a copyable template for each Tier-1 artifact, MUST ship the Tier-3 source-doc templates, and MUST NOT introduce per-artifact `.swarm.*` names for the working artifacts (audit/research/bug-report/finding/adr are plain `.md`); the obligation source is the single human-authored compiler-visible artifact `spec.swarm.md` (§29.2). Extended types (constitution, migration-plan, benchmark/cleanup reports) remain **specializations** that reuse a parent artifact's template, frontmatter, and stance, and MUST NOT acquire their own block types, lint codes, or IR node kinds (§29.4).

## Alternatives considered

| Alternative | Why rejected |
| --- | --- |
| Keep only the earlier four document types | They name upstream sources but leave trace, finding, memory, and the verdict with no structured home; completion claims and durable knowledge have nowhere to live (§29, §29.3). |
| Model the verdict as a standalone `verdict.md` file | A verdict is the *output* of a review pass, so it is a SOL block inside the `review.md` container, never a free-standing artifact (§20.2.3, §29.3). |
| Give each extended type its own block types / lint codes / IR kinds | Extended types differ only in conventional content; duplicating the language machinery would fork the obligation model for no semantic gain (§29.4). |
| Give audit/research/bug-report/finding their own `.swarm.*` names | The `.swarm.` infix marks the one human-authored compiler-visible source; working artifacts are plain `.md` and parse under artifact contracts, not the SOL grammar (§29.2, §20.1). |
| Let an audit author its own obligation blocks (collapse stances) | Smuggling intent into an observation-only artifact is a distillation error; observed risk acquires obligation force only by promoting *into* a spec (§29.1, §29.5). |

## Consequences

### Positive

- Implementation claims, judged verdicts, durable facts, and recall each have a single, contract-defined home, so provenance and drift can be tracked end to end.
- Every artifact's epistemic stance is preserved on promotion, so a lower-stance source cannot masquerade as approved intent (§29.1).
- One verdict location (`review.md`) and one obligation source (`spec.swarm.md`) remove the ambiguity of a free-standing verdict file or competing source names.

### Negative

- The artifact catalogue is larger than the earlier four; adopters must learn the trace/finding/memory roles and the stance discipline.
- The "no `verdict.md`" rule is a constraint a future conformant tool MUST honour by convention; nothing in the markdown layer prevents someone authoring a stray file.

### Neutral / tradeoffs

- Forbidden compositions are enforced by the distillation-loss budget (§24) and source authority (§22), not by a gatekeeper skill (§29.5) — a deliberate relocation of the same prohibition into the language/reference layer.
- Extended types stay available as named variants but inherit their parent's machinery, trading bespoke modelling for a smaller, stable type system (§29.4).

## Status

Accepted (v0.1).

## Affected obligations / constraints

- Adds: the trace, the VERDICT block (inside `review.md`), the finding, and the memory recall layer as kernel artifacts (§29.3).
- Adds: the conformance requirement to ship a contract + template for each Tier-1 artifact and the Tier-3 source-doc templates (§20.3, §20.4).
- Modifies: the four-document model of ADR 0001 — recast onto the unified artifact set while keeping each source document's epistemic stance (§29; ADR 0001 kept verbatim).
- Supersedes: none.
