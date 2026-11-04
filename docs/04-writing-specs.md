# Specs

A spec turns decided intent into obligations an agent can prove. Use `sus-spec` when that structure
will change execution or review. State trivial work inline.

## Minimum shape

```markdown
---
type: spec
id: SPEC-checkout
title: Expired checkout sessions
status: ready
owner: checkout-team
sources:
  - SHOP-4012
---

# Expired checkout sessions

## Intent

Reject expired checkout sessions without converting an expected client condition into a server
failure.

## Requirements

### AC-001 - Expired session returns 409
- When: a checkout session is older than 30 minutes
- Then: the API MUST return `409 SESSION_EXPIRED`, never a 5xx
- Verify with: `npm run test:integration -- expired-session`
```

`Intent` and `Requirements` are required. Add `Non-goals`, `Open questions`, `Affected areas`,
`Dropped from sources`, or `Execution` only when they carry information. Empty headings prove
nothing.

## Requirements

Each requirement:

- has a stable `AC-NNN` ID;
- has exactly one non-empty `When`, `Then`, and `Verify with` item, in that order;
- states one observable behavior in `Then`;
- names its actor or system in `Then`;
- uses exactly one binding word in `Then`;
- contains no unresolved uncertainty.

Resolve discoverable facts and reversible conventions. Put unresolved material decisions under
`Open questions`, keep the spec `draft`, and block dependent work. `ready` is a claim: no blocking
decision or unresolved marker remains.

Exact frontmatter and optional sections: [artifact formats](reference/artifact-formats.md).

Next: [inventories and change plans](05-brownfield-and-change-plans.md). Previous:
[artifact location and close](03-where-files-live.md).
