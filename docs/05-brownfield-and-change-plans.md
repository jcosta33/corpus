# Inventories and change plans

```text
inventory -> spec -> change plan -> task split when needed -> implement -> review
```

Add only the structure the work needs. If you cannot name current behavior, you cannot promise to
preserve it. `sus-inventory` records present reality. `drill` locks language, obligation, place, then slice;
it writes no Suspec file. `sus-change-plan` defines a behavior-preserving transformation when ordered
waves and rollback must outlive the session. Inventory and change-plan files use the
[agent-neutral artifact location](03-where-files-live.md).

## Inventory

Use an inventory when ownership, behavior, tests, interfaces, dependencies, or constraints remain
unclear. Record:

- relevant files and modules;
- observed behavior and public interfaces;
- existing tests;
- constraints and dependencies;
- unknowns;
- file or line evidence for every structural claim.

Inventory observes. It does not pitch a redesign. Review it by hand.

## Change plan

Use `drill` when the next write is one seam and ordered waves plus rollback need not
outlive the session. Do not write `type: change-plan` for that path.

Use a change plan for migrations, rewrites, schema changes, broad refactors, dependency upgrades, or
staged performance work. It adds:

- baseline and target state;
- preservation guarantees;
- ordered waves;
- verification per wave;
- cutover and rollback.

The source spec owns product requirements. The plan owns transformation order and preservation
context.

Prefer existing requirement references:

```yaml
preserves:
  - SPEC-checkout#AC-001
```

Use `PG-NNN` only for plan-local guarantees. Put lasting behavior in tests, public contracts, or
project decisions.

Each wave must leave the codebase usable and verifiable. When a wave becomes a task, that task still
names the source spec and its scoped requirement IDs.

## Live drift

When code or evidence contradicts the working spec, stop. Either intent changed or something is
wrong. Update the spec in the first case; fix code in the second. Record any lasting decision through
the project's own channel. After close, start later work from current code and durable records, not
old transient artifacts.

Skip both documents for local work whose behavior, ownership, and tests are already clear.

Next: [tasks](06-creating-tasks.md). Previous: [specs](04-writing-specs.md).
