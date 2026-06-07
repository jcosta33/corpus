---
type: spec
id: contact-form
swarm_language: SOL/0.1
aps_version: 0.1
spec_version: 0.1.0
status: draft
---

# Contact form — example spec

A minimal `*.swarm.md` to copy. Prose explains; the **SOL blocks** carry the load-bearing requirements an
agent must satisfy. This spec anchors its feature folder `specs/001-contact-form/`; its supporting docs (see
`research.md` beside it) live in the same folder. Rename the folder and delete these examples once you have a
real feature.

## Intent

Show the shape of a spec: an intent, a couple of obligations, and how each binds to a proof.

## Obligations

REQ AC-001:
WHEN a user submits the contact form with a valid email
THE service MUST persist the message and return a 201
VERIFY BY test:cmdTest:contact_form.submit_valid

REQ AC-002:
IF the email is missing or malformed
THEN THE service MUST reject the submission with a 422 and not persist anything
VERIFY BY test:cmdTest:contact_form.reject_invalid

## Constraints

CONSTRAINT C-001:
THE service MUST NOT store the raw message body in logs
VERIFY BY static:cmdLint:no-pii-in-logs

## Verification coverage

Every obligation above binds a `VERIFY BY`; the `<adapter>` slots (`cmdTest`, `cmdLint`) resolve through the
consuming repo's `AGENTS.md > Commands` table.
