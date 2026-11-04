# Lineage

```text
request/source -> working spec -> implementation -> review -> findings decision
                         \
                          -> split task, when earned
```

- A spec names upstream sources.
- A task names its spec and copies assigned requirement IDs. A change plan may add wave context.
- A review receives its spec and optional task explicitly.
- Evidence names the requirement and command it supports.
- A durable finding names evidence and moves to native memory or a project channel.

IDs reconcile live work; they do not summon a registry. Requirement IDs are spec-scoped. Cross-spec
references use `SPEC-id#AC-NNN`.

Every producer reports an absolute path. Every consumer receives it.

After close, code, tests, decisions, issues, PRs, maintained documentation, and supported memory hold
durable lineage. Promotion moves a whole artifact into a project-owned destination by default. It
retains a transient copy only when the human explicitly selects that exception. It creates no registry.

Related: [artifact location](../03-where-files-live.md)
