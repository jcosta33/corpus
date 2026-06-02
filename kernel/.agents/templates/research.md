---
type: research
id: {{slug}}
status: open
created: {{createdAt}}
updated: {{createdAt}}
---

# Research: {{title}}

<!--
  STANCE: investigation / inquiry. This document SURVEYS options and evidence and
  commits to NO decision. It records what the inquiry has found and what remains
  open; it does NOT author REQ / CONSTRAINT / INVARIANT / INTERFACE obligation
  blocks. Those are produced only when this research promotes to a `spec.swarm.md`
  via the author pass (§9). As a detached first-class evidence store, one research
  artifact MAY feed many PRDs, specs, ADRs, findings, or audits at once (§20.3.4).

  REQUIRED sections (in order, §21.9): Question · Findings · Open questions · Recommendation.
  Inert reference data: nothing here executes (NO RUNTIME, §2).
-->

## Question

<!-- The single, specific, decision-informing question this inquiry exists to answer.
     One or two sentences. If it cannot be stated concisely, the scope is unclear. -->

{{question}}

## Findings

<!-- The surveyed evidence. Each finding is a citable span with a stable local id of
     the form R-NNN, so a downstream artifact can reference it as `<this-id>#R-NNN`
     (the §20.3.4 cross-file ref convention, e.g. password-recovery-survey#R-002).
     Each finding promotes to a standalone `finding.md` (§21.6) when accepted.
     Survey the options/evidence; draw no conclusion here. -->

### R-001 — {{finding title}}

- **Claim:** <the one durable fact this finding asserts>
- **Evidence:** <file / command / output / external source — enough to re-verify or re-find>
- **Confidence:** <high | medium | low>
- **Bears on:** <which downstream question, option, or obligation-to-be this informs>

### R-002 — {{finding title}}

- **Claim:** <what goes here>
- **Evidence:** <what goes here>
- **Confidence:** <high | medium | low>
- **Bears on:** <what goes here>

## Open questions

<!-- Unresolved points the inquiry surfaced but did not settle. Each is a QUESTION
     candidate (Q-NNN) and MUST remain open until resolved (§11); it carries forward
     to the promoted spec rather than being silently dropped. Do not resolve a
     question here by asserting a decision — that would break the inquiry stance. -->

- [ ] **Q-001** — <unresolved point; what answering it would unblock>
- [ ] **Q-002** — <what goes here>

## Recommendation

<!-- A specific, actionable recommendation the spec author can lift into a
     `spec.swarm.md` during the author pass. State the recommended direction and the
     findings (R-NNN) that ground it — but author no obligation blocks here; the
     recommendation is advisory, not a committed decision. If no recommendation is
     possible, state WHY and what would unblock one (typically an open Q-NNN). -->

{{recommendation}}

<!--
  PROMOTION: this research promotes to a `spec.swarm.md` via the author pass (§9).
  Accepted findings (R-NNN) become `finding.md` artifacts; open questions (Q-NNN)
  carry forward as the spec's QUESTION blocks; the recommendation seeds the spec's
  obligations. Until then this document is non-authoritative evidence (§22).
-->
