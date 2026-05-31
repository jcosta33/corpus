# Conformance violations — expected-FAIL fixtures

One minimal example per violation class. Each must make a checker return **non-conformant**,
citing the named rule from `../conformance.yaml`. This is the checker's regression suite: if a
checker passes any of these, the checker (or the manifest) is wrong.

---

## V1 — empty paste slot (`content_rules: non-empty-paste`)

```markdown
### Verification outputs (paste actual command output — do not paraphrase)

- `{{cmdValidate}}` (last 2 lines):
- `{{cmdTest}}` (last 2 lines):
```

**Expected:** FAIL — required paste slots are bare placeholders (no fenced output, no `n/a` + reason). This is the hallucinated-completion hole the gate exists to surface.

---

## V2 — missing required section (`task_file.required_sections`)

A task file with `## Metadata`, `## Plan`, and `## Self-review` but **no `## Objective`** and **no `## Linked docs`**.

**Expected:** FAIL — `Objective` and `Linked docs` are required; the task is ungrounded.

---

## V3 — missing required `Commands` row (`agents_md.required_command_rows`)

An `AGENTS.md > Commands` table binding `Validation` and `Test` but **omitting `Format`**.

**Expected:** FAIL — `Format` is a required command row; skills that close a session by formatting have nothing to resolve.

---

## V4 — illegal placeholder namespace (`placeholders.rule`)

A template introducing `{{cmdFrobnicate}}` — a new `cmd*` slot absent from the catalogue and introduced without an ADR.

**Expected:** FAIL — the `cmd*` namespace is reserved; new slots require an ADR. (A vendor extension would be `{{vendor:frobnicate}}`, which is legal.)

---

## V5 — unresolved `[CRITICAL]` at close (`content_rules: no-open-critical`)

```markdown
## Open questions

- [ ] **[CRITICAL]** Which auth scheme — resolve before implementing.
```

…in a task file whose `## Metadata` says `Status: done`.

**Expected:** FAIL — a `[CRITICAL]` open question is unresolved while the task claims completion.

---

## V6 — required-suite slot missing for the task type (`required_suite`)

A `refactor` task whose `### Verification outputs` pastes `{{cmdTest}}` but has **no `behaviour-preservation` evidence and no `{{cmdValidateDeps}}` checkpoint**.

**Expected:** FAIL — the `refactor` required suite includes `ValidateDeps`, `Typecheck`, `Test`, and `behaviour-preservation`; a green test suite alone is not equivalence proof.
