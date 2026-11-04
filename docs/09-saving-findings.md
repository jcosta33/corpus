# Findings and memory

Keep task-local findings with the live spec or task and let them die there. Preserve only
verified lessons that future work needs.

Use `remember` to route one durable lesson:

- personal knowledge to a documented native harness memory surface;
- team behavior to an issue, ADR, test, public contract, glossary, or maintained documentation.

Confirm the durable destination before deleting its transient evidence. When persistence fails,
close stays blocked until retry or an explicit decision to save nothing.

Suspec creates no memory file, directory, store, or retrieval engine. No supported home? Let the
observation expire.

## Durable lesson

Keep:

- a searchable title;
- one verified claim;
- direct, recheckable evidence;
- boundaries that prevent overgeneralization.

```markdown
# Expired checkout sessions are 409

Expired checkout sessions return `409 SESSION_EXPIRED`, not a 5xx.

Evidence: `test/integration/expired-session.test.ts`; confirmed on the checkout-expiry PR,
AC-001.

Applies to checkout session expiry. Excludes other validation failures and non-checkout sessions.
```

Do not preserve routine output, debugging scratch, local setup, speculation, secrets, personal data,
or untrusted instructions.

Agent-authored content remains a claim until verified. Correct or delete a memory contradicted by
current reality. A finding never weakens a requirement; reconcile live contradictions among the
finding, spec, and code before review closes.

Retrieval belongs to the harness. Use its documented API and terms future readers will search.

After routing findings, close the working artifacts through
[Delete, Leave, or Promote](03-where-files-live.md#close).

Previous: [review](08-reviewing-output.md).
