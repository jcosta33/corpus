<!-- checks fixture — expected results pinned in EXPECTED.md (this file) -->

# cross-folder-source — expected check results

Checks fixture for [the check catalogue](../../../docs/reference/checks.md), pinning **C009
(`broken-source-link`) resolution across folders** — the doc-recommended layout where a spec at
`specs/<feature>/spec.md` cites a ticket captured at the **workspace root** under `intake/`.

This is the case the shipped worked example (`examples/feature-from-ticket/`) **masks**, because
that example co-locates its `ticket.md` _beside_ the spec — so a spec-dir-only resolver passes it
while silently failing the far more common root-level `intake/x.md` layout that `corpus pull` +
`corpus new spec` scaffold. This fixture restores the cross-folder case.

## Layout

```
cross-folder-source/
  intake/sup-204.md          <- captured by `corpus pull` at the workspace root
  specs/triage/spec.md       <- sources: [intake/sup-204.md]   (a workspace-root-relative path)
```

## Expected results — `corpus check specs/triage/spec.md`

| Check                     | Where                        | Expected result                                                                                                                                                                                  | Severity                |
| ------------------------- | ---------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------- |
| C009 `broken-source-link` | `sources: intake/sup-204.md` | **resolves** — the ref exists at the **workspace root** (`intake/sup-204.md`), so C009 is clean even though it does not exist relative to the spec's own dir (`specs/triage/intake/sup-204.md`). | hard error (not raised) |
| C001 `unique-ids`         | AC-001..AC-003               | unique → clean                                                                                                                                                                                   | hard error              |
| C003 `verify-with`        | every AC                     | each carries a `Verify with:` line → clean                                                                                                                                                       | hard error              |
| C004 `one-strength-word`  | every AC                     | exactly one strength word each → clean                                                                                                                                                           | warning                 |
| C008 `sources-named`      | frontmatter                  | names a source → clean                                                                                                                                                                           | warning                 |

**Net:** `✓ clean` (exit 0). The C009 resolver checks a `sources:` ref against **both** the spec's
own directory AND the workspace root; only a ref that exists under neither is a broken link. A
genuinely-missing root ref (e.g. `intake/nope.md`) still fails C009.

> Toolable — `corpus check` implements exactly this. Until the tool runs in a given workspace,
> reviewers read this table as the checklist.
