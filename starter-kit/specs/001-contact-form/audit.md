---
type: audit
id: contact-form-present-state
status: draft
created: 2026-06-07
updated: 2026-06-07
---

# Audit: contact-form present state

*Lives in: `specs/001-contact-form/` — beside the spec whose feature it audits (co-located supporting doc).*

> Stance: **observation-only**. This records what the existing contact endpoint *is* — present-state risk and
> debt — and asserts no new intended behaviour. It authors no `REQ`/`CONSTRAINT`/`INVARIANT`/`INTERFACE`
> blocks; its observations acquire obligation force only when the `author` step promotes them into the spec
> beside it. This is an **example** co-located supporting doc — delete it with the rest of the example.

## Scope

- **In scope:** the present-state behaviour of the existing contact-form submit path.
- **Out of scope:** the rich-text editor, spam/abuse defenses, analytics.

## Observations

- The submit handler logs the full request body on error — evidence: `server/contact/submit.ts:42`
  (`logger.error({ body }, ...)`). The raw message body reaches the logs.
- Email is validated only client-side; the server persists whatever it receives — evidence:
  `server/contact/submit.ts:18` (no server-side validation before the insert).

## Risks

- **PII in logs** — fires when any submission errors: the raw body (which may contain personal data) is
  written to a log sink with a longer retention than the database.
- **Malformed/garbage rows** — fires when a client bypasses the form (direct POST): unvalidated input is
  persisted, with no 422 path.

## Recommended obligations

*(Prose only — candidate obligations a downstream `author` step would promote into the spec beside this file.)*

- The server should reject a missing/malformed email with a 422 and persist nothing. (→ became `REQ AC-002`.)
- The server should never write the raw message body to logs. (→ became `CONSTRAINT C-001`.)
