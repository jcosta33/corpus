---
type: adr
id: adr-0125
status: accepted
created: 2026-07-02
updated: 2026-07-02
---

# ADR-0125 — Re-mint `malformed-requirement-heading` as C019; the C018 reservation stands

## Context

The `malformed-requirement-heading` check shipped on 2026-07-02 under the id **C018** (contract
0.9.0 → 0.10.0) with no minting ADR — and C018 was not free: [ADR-0097](./0097-mint-c016-c017-defer-oversized.md)
explicitly **reserves C018 for the oversized-packet check** ("the `CheckId` set stops at C017"), and
[ADR-0094](./0094-decomposition-and-risk-weighted-review.md) repeats the reservation. A same-day
multi-lens panel review (DP-8 in the family workspace's `FINDING-review-gate-measurement`) caught
the collision, plus two behavior defects in the shipped check: the detection regex false-fires on
prose group headings whose first token is NAME-digits-LETTERS (`### UTF-16LE handling` captures
`UTF-16LE`), and the diagnostic can quote a truncated token (`### AC-4a-extra` reports `AC-4a`).

The owner's decision (2026-07-02): re-mint under the next free id rather than reinterpret two
accepted ADRs, and fold the regex tightening into the same change.

## Decision

### D1 — C019 `malformed-requirement-heading`, **warning** (contract 0.10.0 → 0.11.0)

The check keeps its meaning and severity; only the id moves. A `###` heading shaped like a
requirement id but carrying a **lowercase split-suffix** (`AC-004a`) parses as plain prose — the
requirement silently vanishes from scope and coverage — and C019 makes the disappearance visible.
The fix remains a digits-only id: a split requirement gets its own number, never a suffix.

### D2 — C018 stays reserved

The [ADR-0097](./0097-mint-c016-c017-defer-oversized.md)/[ADR-0094](./0094-decomposition-and-risk-weighted-review.md)
reservation of C018 for a future oversized-packet/decomposition-predictive signal is untouched and
back in force. `checks.yaml` carries an explicit reservation comment so the next mint cannot collide
by accident.

### D3 — the detection shape narrows to the lowercase split-suffix

The regex requires the first suffix character to be **lowercase**
(`/^###\s+([A-Z][A-Z0-9]*-\d+[a-z][A-Za-z0-9_]*)/`), because the split-suffix convention the check
exists to catch is lowercase (`AC-004a`, `AC-004b`) while the measured false-positive class is
uppercase-continuation prose (`UTF-16LE`, `C-3PO`). The capture continues through word characters
(no trailing `\b`), so `### AC-004a_note` is caught whole and the diagnostic quotes the full token.

**Recorded residual risks (accepted, not silent):** an UPPERCASE-suffixed id-like heading
(`### AC-004A`) reads as a prose group heading and is not flagged — no instance observed in the
family corpus, and warning-severity noise on prose was measured the worse error; a tab after `###`
follows CommonMark for the parser but is outside this check's shape; a malformed **SOL** opener
(`REQ AC-004a:`) is structural-check territory for the SOL catalogue (`SOL-S*`), not a spec-form
C-check — recorded there as future work, not minted here.

## Consequences

- `checks/checks.yaml` is the registry of record: `version: 0.11.0`, C019 minted, C018 commented as
  reserved. suspec-cli pins `CONTRACT_VERSION = '0.11.0'` and its sibling drift guard reconciles the
  two on every CI run.
- The oversized-packet advisory in `suspec review` (neutral size info, no band) is unchanged and its
  in-code references to "C018 (oversized-packet)" are correct again under the restored reservation.
- Minting discipline is restated by example: **a contract id ships with its ADR** — the missing-ADR
  gap this re-mint closes is the collision's root cause, not the id arithmetic.

## Status

Accepted (2026-07-02).
