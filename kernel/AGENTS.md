# AGENTS.md

<!--
  Swarm bootloader template (§31). This is the ALWAYS-LOADED file every task reads first.
  Copy it to your project ROOT and fill the {{placeholders}}. Keep it FACTS-ONLY.

  HARD CAP (§31.1): MUST stay <= 200 lines / 25 KB; SHOULD target ~50-150 lines.
  A conformant repo MUST have a regression check that fails when this file exceeds the cap.

  WHAT BELONGS HERE (§31.2): persistent facts the model cannot infer, the Commands
  contract, one-line POINTERS into memory and the language reference, and a small set of
  universal startup + "do not" rules.

  WHAT MUST STAY OUT: pass procedures, how-to-review/audit/migrate steps, full memory
  content, and the SOL/APS manual. Those live in `.swarm/kernel/` and load on demand.
  This file carries at most a one-line pointer to the language reference, never the manual.
-->

## Swarm startup
<!-- The always-on doctrine (the load-what-the-task-names rule, §26.4, plus the universal invariants).
     Keep these as facts/rules, never step-by-step procedures (§31.2). -->
1. Read the current task file first.
2. The Swarm workspace is `.swarm/` (canonical intent, status, memory, and the installed kernel; §20.5).
3. Treat `.swarm.md` blocks as authoritative over prose summaries.
4. Use assigned obligation IDs as scope.
5. Load only the pass / profile / context files the task names.
6. Map every completion claim to evidence.
7. Promote durable discoveries before closing.

## Universal rules
<!-- The universal "do not" invariants. Conditional / task-kind-specific rules go in
     task templates or profiles, not here. -->
- Do not implement behavior outside assigned obligations.
- Do not treat chat as higher authority than an approved spec or ADR.
- Do not close a task with unhandled promotion items.
- Do not claim completion without evidence.

## Project facts
<!-- Persistent facts an agent cannot infer: stack, conventions, boundaries the project relies on.
     One bullet per fact. Delete this section if the project has none worth stating. -->
- {{persistent-fact-the-model-cannot-infer}}
- {{persistent-fact-the-model-cannot-infer}}

## Pointers
<!-- One-line pointers ONLY — never inline the target content (§31.2). -->
- Language reference (SOL / APS / errors / versioning): `.swarm/kernel/language/`
- Memory recall map (says *when to load* each entry; never dumped here): `.swarm/memory/INDEX.md`
- Passes, skills (pass guides), profiles, overlays: `.swarm/kernel/`

## Compatibility
`.agents/` MAY hold compatibility mirror files for agent tools (skills, profiles, thin task
pointers), each pointing back to its canonical `.swarm/kernel/` (or `.swarm/generated/`) original.
Canonical Swarm artifacts live in `.swarm/` (§20.5).

## Commands
<!--
  The Commands contract (§31.3). This is a FACT (a binding), which is why a table is allowed
  in an otherwise facts-only file. Each `cmd*` slot is the adapter a
  `VERIFY BY <type>:<adapter>:<artifact>` clause resolves through (§15).

  NORMATIVE:
  - Populate a `cmd*` row for EVERY proof type any `VERIFY BY` clause in this repo references.
    An unresolved adapter is a verification-layer lint defect (SOL-V002) and a BLOCKED verdict
    at the gate (§14); a missing required `cmd*` row is a negative conformance-fixture class (§33).
  - This is SOFT CONTROL (§17): the table names what a future launcher WOULD run. Nothing here
    is executed, and this file MUST NOT claim it enforces or runs these commands.

  Fill the Command column; add or remove rows to match the proof types this repo actually uses.
-->
| Slot         | Command                  | Resolves proof types |
| ------------ | ------------------------ | -------------------- |
| cmdTest      | `{{test-command}}`       | test                 |
| cmdLint      | `{{lint-command}}`       | static               |
| cmdTypecheck | `{{typecheck-command}}`  | static               |
| cmdBenchmark | `{{benchmark-command}}`  | perf                 |
| cmdValidate  | `{{validate-command}}`   | static (aggregate)   |
| cmdFormat    | `{{format-check-cmd}}`   | (format hygiene)     |
