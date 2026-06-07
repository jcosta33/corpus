---
type: research
id: contact-form-spam
status: open
created: 2026-06-07
updated: 2026-06-07
---

# Research: contact-form submission validation

*Lives in: `specs/001-contact-form/` — beside the spec it informs (co-location is the whole point of the feature folder).*

This is an **example** of a feature-scoped supporting doc sitting next to the spec it feeds. A real one would
survey the evidence behind a spec's obligations; here it just shows where such a doc lives. Delete it with the
rest of the example.

## Question

What server-side validation must the contact form enforce so a malformed or hostile submission cannot persist
bad data — and which of those rules belong as obligations in `spec.swarm.md`?

## Findings

### R-001 — email must be validated server-side

- **Claim:** client-side validation is bypassable; the server MUST reject a missing/malformed email itself.
- **Evidence:** standard web-security guidance (never trust the client); observed in similar forms.
- **Confidence:** high
- **Bears on:** `REQ AC-002` in `spec.swarm.md` (reject invalid with 422, persist nothing).

## Open questions

- [ ] **Q-001** — should the raw message body ever be logged for debugging? (informs `CONSTRAINT C-001`)

## Recommendation

Bind every accept/reject path to a `test` proof and forbid logging the raw body (a `static` proof). These
became `AC-001`, `AC-002`, and `C-001` in the spec beside this file.
