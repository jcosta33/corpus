---
type: adr
id: adr-0070
status: accepted
created: 2026-06-12
updated: 2026-06-12
---

# ADR-0070 — `checks/` is the home of the checks contract

## Context

ADR-0066 renamed the corpus framing to "checks fixtures" and ADR-0054 purged the
compiler-register vocabulary from reader-facing content — but the directory stayed
`conformance/` and its data file `conformance.yaml`. The result is a vocabulary fork the owner
review (2026-06-12) called out: every prose surface says _checks_; the tree says
_conformance_, a standards-body register that reads as more of the formal-methods cosplay the
repositioning removed. It also misleads structurally: a top-level `conformance/` beside
`docs/examples/` reads as a second examples pile rather than as test data for a contract.

## Decision

1. **`conformance/` → `checks/`; `conformance.yaml` → `checks/checks.yaml`.** The directory
   matches its canonical prose home, `docs/reference/checks.md`. The yaml's `version` bumps
   0.2.1 → 0.3.0 — the path is consumer-visible contract surface and corpus-cli has not shipped,
   so this is the cheapest the rename will ever be.
2. **The counts registry's producer home is now `checks/README.md`** — the two-home rule
   (ADR-0057 §5) is unchanged; one of the homes moved with its file.
3. **Live surfaces update in the same commit; ADR bodies keep the historical name** per the
   immutability rule — the ledger row notes the rename.

## Alternatives considered

- **Keep `conformance/`** — "conformance suite" is technically accurate standards language,
  but the framework spent ADRs 0054/0057/0063/0066 choosing the practical register; a
  top-level directory is the most visible vocabulary surface in the repo.
- **Fold the fixtures under `docs/`** — they are test data with a named consumer (corpus-cli's
  oracle; a reviewer applying the checks by hand), not reading material.

## Consequences

Accepted. Completes the register sweep of ADR-0054 at the tree level; refines ADR-0066
(same content, honest name). All `conformance/` and `conformance.yaml` references on live
surfaces move to `checks/` and `checks/checks.yaml`.

## Propagation

directory rename, checks/README + checks.yaml internal prose, docs/reference/{checks,
cheatsheet}, root bootloader AGENTS.md, kit cards that name the yaml, propagation matrix.
