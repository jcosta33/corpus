---
# checks fixture — expected results pinned in the EXPECTED note at the end of this file
type: intake
source: JIRA-123
url: https://example.test/browse/JIRA-123
captured: 2026-06-11
---

# Intake: Customers logged out mid-checkout

**Reporter:** support-escalations
**Priority:** High
**Labels:** auth, checkout

Customers report being dumped to the login screen while paying. Sessions seem to expire
after 15 minutes no matter what they're doing. We need them to stay logged in — extend the
session or refresh it silently. Also the login page loses the cart when they sign back in.
Probably related?

Notes from triage call:

- Keep the user in checkout when their token expires.
- Don't weaken token lifetime policy without security sign-off.
- Cart persistence might be a separate ticket — TBD.

<!--
EXPECTED — pinned results for this fixture:

- Valid intake. The frontmatter carries type / source / url / captured, and the body is the
  upstream ticket content, unedited. Nothing more is required of an intake.
- The vague asks ("seem to", "probably related", the TBD) stay verbatim by design — the
  intake preserves what was actually asked; the spec that names this file in its `sources:`
  is where they get resolved or lifted into Open questions. No check fires on intake prose.
- Spec checks (C001–C009, SOL codes) do not apply to an intake. A future `corpus check`
  would validate only the frontmatter shape; until then this is a convention — nothing in
  this repository enforces it.
-->
