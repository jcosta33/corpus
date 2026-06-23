# Corpus Reference

*Works today — plain markdown plus your agent; no Corpus tooling required.*

One page of lookup tables: labels, results, verification methods, artifact homes, the loop, and
the check ids. Definitions live in the linked pages; the exact file formats live in the kit
templates ([`templates/`](https://github.com/jcosta33/swarm-starter-kit/tree/main/templates/)) and are never restated here.

## The loop

```
Pull → (Inventory) → Spec → (Change Plan) → Task → Run → Review → Close
        brownfield          structural
```

| Step                            | What it produces                                                |
| ------------------------------- | --------------------------------------------------------------- |
| **Pull**                        | an intake file — the upstream ticket, captured verbatim         |
| **Inventory** _(conditional)_   | a map of existing code before structural/brownfield work        |
| **Spec**                        | intent, non-goals, requirements with `Verify with:` lines       |
| **Change Plan** _(conditional)_ | how the codebase changes while named behavior provably survives |
| **Task**                        | a bounded task packet an agent can run                          |
| **Run**                         | the change, on its own branch, plus an agent run summary        |
| **Review**                      | a review packet — requirement coverage, evidence, exceptions    |
| **Close**                       | merge or block, board update, findings saved                    |

Not every task needs every step — the skip rules and per-shape flows are in
[the basic workflow](../02-basic-workflow.md).

## IDs and labels

| Prefix     | Artifact      | Example                  |
| ---------- | ------------- | ------------------------ |
| `SPEC-`    | spec          | `SPEC-auth-refresh`      |
| `TASK-`    | task packet   | `TASK-auth-refresh-1`    |
| `REVIEW-`  | review packet | `REVIEW-auth-refresh-1`  |
| `FINDING-` | finding       | `FINDING-rotated-tokens` |
| `INV-`     | inventory     | `INV-billing`            |
| `CHANGE-`  | change plan   | `CHANGE-billing-split`   |

Requirement labels inside a spec:

| Label    | Meaning                                              | Where    |
| -------- | ---------------------------------------------------- | -------- |
| `AC-NNN` | acceptance criterion — a verifiable requirement      | any spec |
| `C-NNN`  | constraint — restricts _how_ requirements may be met | SOL form |
| `I-NNN`  | invariant — a property that must keep holding        | SOL form |
| `IF-NNN` | interface — a declared boundary                      | SOL form |
| `Q-NNN`  | open question, optionally `[blocking]`               | SOL form |

A file's identity is its frontmatter `type:`, never its filename — see
[artifact formats](artifact-formats.md). SOL is the optional structured-requirements notation
(`format: sol`) — see [structured requirements](structured-requirements.md).

## Review results

One result per requirement row in the review packet (internally: verdicts).

| Result         | Meaning                                                                 |
| -------------- | ----------------------------------------------------------------------- |
| **Pass**       | Verified — pasted output, a CI link, or a named human's recorded observation (manual method) sits in the Evidence cell. |
| **Fail**       | Verified, and the requirement is not met.                               |
| **Unverified** | No evidence. Every empty Evidence cell reads as Unverified, never Pass. |
| **Blocked**    | Cannot be verified until something else is resolved.                    |

Lifecycle results, used in advanced workflows to qualify an earlier result:

| Result           | Meaning                                                                                                            |
| ---------------- | ------------------------------------------------------------------------------------------------------------------ |
| **Waived**       | A Fail or Unverified explicitly accepted by a named human, with reason and expiry.                                 |
| **Stale**        | A prior Pass whose evidence predates a change to the requirement or the code it exercised — see [drift](drift.md). |
| **Contradicted** | Two pieces of evidence disagree, or the code disagrees with the requirement.                                       |

The evidence rules and exception triggers are in [reviewing output](../08-reviewing-output.md).

## Verification methods

What kind of evidence backs a requirement's `Verify with:` line (internally: proof types).

| Method     | One line                                                                                               |
| ---------- | ------------------------------------------------------------------------------------------------------ |
| `test`     | An executable test exercises the behavior (unit/integration/e2e are scopes of this one method).        |
| `static`   | Type-check, lint, build, or static analysis over the code as written.                                  |
| `contract` | A boundary check against a declared interface — API schema, consumer contract.                         |
| `property` | A property-based check over generated inputs; strong for invariants.                                   |
| `model`    | An exhaustive or model-checked argument; the strongest, and the rarest.                                |
| `perf`     | A measured benchmark against a stated budget.                                                          |
| `security` | A scanner or a targeted security test against an attack class.                                         |
| `manual`   | A named human checked it and recorded what they saw — always with a reason and the observation itself. |
| `monitor`  | A production probe or alert observes the behavior after merge.                                         |

## Artifacts and where they live

| Artifact                                                         | Tier                                           | Home in the workspace                                    |
| ---------------------------------------------------------------- | ---------------------------------------------- | -------------------------------------------------------- |
| intake                                                           | core (recommended for tracker-originated work) | `intake/`                                                |
| spec                                                             | core                                           | `specs/<feature>/spec.md`                                |
| task packet                                                      | core                                           | `tasks/`                                                 |
| review packet                                                    | core                                           | `reviews/`                                               |
| finding                                                          | core                                           | `findings/`                                              |
| status board                                                     | core                                           | `status.md`                                              |
| inventory                                                        | core when the work is brownfield               | `inventory/`                                             |
| change plan                                                      | core when the work is structural               | `change-plans/`                                          |
| adr                                                              | advanced                                       | `decisions/`, numbered                                   |
| audit · bug · research · rfc · prd · threat-model · release-note | advanced                                       | co-located in `specs/<feature>/` |

The full layout, both naming depths, and the code-repo boundary are in
[where files live](../03-where-files-live.md); every format is catalogued in
[artifact formats](artifact-formats.md).

## Checks — the quick list

Common mistakes to check for in a spec — plus the two change-plan checks. **Level: checklist today; toolable — swarm-cli's
`swarm check` implements this list.** Full descriptions, the honesty legend, and the SOL
catalogue are in [checks](checks.md).

| ID   | Name                                                                       | Severity   |
| ---- | -------------------------------------------------------------------------- | ---------- |
| C001 | `unique-ids` — every requirement ID appears exactly once                   | hard error |
| C002 | `duplicate-id` — no other file claims the same `id:`                       | hard error |
| C003 | `verify-with` — every requirement carries a `Verify with:` line            | hard error |
| C004 | `one-strength-word` — exactly one of must / must not / should / should not / may | warning |
| C005 | `non-goals-present` — a non-empty Non-goals section exists                 | warning    |
| C006 | `open-questions-present` — an Open questions section exists                | warning    |
| C007 | `no-tbd-at-ready` — no `TBD`/`TODO`/unresolved question at `status: ready` | hard error |
| C008 | `sources-named` — frontmatter `sources:` names at least one origin         | warning    |
| C009 | `broken-source-link` — every named source resolves                         | hard error |
| C010 | `preserves-refs-resolve` — change plan only: every preserved id resolves   | hard error |
| C011 | `waves-present` — change plan only: migration/rewrite/schema-change has waves | warning |
| C012 | `coverage` — review packet only: in-scope ids covered, no orphan rows (non-draft spec) | warning |
| C013 | `verify-evidence-binding` — review packet only: a structured `verify` block's cmd matches the requirement's named command + `result=pass` (non-draft spec) | warning |
| C014 | `do-not-change-touched` — review packet only: a changed file matches a task's `## Do not change` entry (distinct from out-of-scope drift) | warning |
| C015 | `citation-resolves` — spec only: an inline `[[KEY]]` citation resolves to a matching `<a id="KEY">` anchor in the named `sources.md` (skips when no `sources.md` is resolvable) | warning |
| C016 | `pass-needs-evidence` — review packet (gate path): a Pass coverage row with an empty Evidence cell blocks (the reconcile path surfaces it advisorily) | hard error |
| C017 | `orphaned-reference` — workspace: a bundled `.agents/skills/<name>/references/<file>` named nowhere in its `SKILL.md` (orphan direction only) | warning |

Packet checks (checklist level): `non-empty-paste` — a completion claim binds to pasted output
or a CI link; `no-open-critical` — nothing closes with an open blocking question;
`trigger-coverage` — the Human attention section considered every exception class.

## Appendix — reference values (producer note)

This appendix exists for producers of Corpus tooling and documentation, not for adopters.
The closed sets have exact sizes that tooling and fixtures reconcile against — the same
eight rows, with their member lists, live in
[`checks/README.md`](../../checks/README.md): block types (SOL form) 5 ·
strength words 5 · review results 7 (4 core + 3 lifecycle) · verification methods 9 ·
loop steps 6 (+ 2 conditional) · lifecycle steps (advanced) 9 · improve operations 10 ·
check layers 5 (S/P/M/V/O). These registry rows — the counts with their member lists —
live in exactly two places: here and there. A change to any set updates both, and the
fixtures, in one commit. (The numeral-bearing model names — the six-step loop, the
nine-step lifecycle — are names, not registry copies.)

## Related

- [The basic workflow](../02-basic-workflow.md) — the loop, per-shape flows, skip rules.
- [Checks](checks.md) — every check in full, with the honesty legend.
- [Glossary](glossary.md) — every term on this page, defined.
- [Step bars](step-bars.md) — what good output looks like, per step of the loop.
- [Principles](principles.md) — the design rationale the rules on this page derive from.
- [The advanced lifecycle](advanced-lifecycle.md) — the finer-grained step model under the loop.
