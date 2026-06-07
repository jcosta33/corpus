# AGENTS.md

<!--
  Swarm bootloader. This is the ALWAYS-LOADED file every task reads first.
  Copy it to your project ROOT and fill the {{placeholders}}. Keep it FACTS-ONLY.

  HARD CAP: MUST stay <= 200 lines / 25 KB; SHOULD target ~50-150 lines.
  A valid repo MUST have a regression check that fails when this file exceeds the cap.

  WHAT BELONGS HERE: persistent facts the model cannot infer, the Commands
  contract, one-line POINTERS into memory and the language reference, and a small set of
  universal startup + "do not" rules.

  WHAT MUST STAY OUT: step procedures and how-to-review/audit/migrate steps (those live in the
  self-contained skills installed beside your own skills, loaded on demand) and full memory content.
  The SOL/APS manual and the step reference are NOT installed — they live in the Swarm project; this
  file names them, never inlines them.
-->

## Swarm startup
<!-- The always-on doctrine (the load-what-the-task-names rule, plus the universal invariants).
     Keep these as facts/rules, never step-by-step procedures. -->
1. Read the current task file first.
2. `.agents/` holds only Swarm tooling: `skills/` (beside your own), `reference/`, `templates/`, `memory/`. Your **specs live in per-feature folders** — `specs/<feature>/spec.swarm.md`, with each feature's supporting docs (audit/research/bug-report/…, `type:`-tagged) beside it; **ADRs** live in `decisions/` (numbered); **findings** live in `.agents/memory/`. No `.swarm/` mount.
3. Treat `.swarm.md` blocks as authoritative over prose summaries.
4. Use assigned obligation IDs as scope.
5. Decide isolation before editing (see the `implement` step): a code task with a source spec/audit runs in a `worktree+branch` named for the spec, off the base — never on it; a bare ad-hoc edit stays `in-place`.
6. Load only the step / profile / context files the task names.
7. Map every completion claim to evidence.
8. Promote durable discoveries before closing.

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
<!-- One-line pointers ONLY — never inline the target content. -->
- Skills (the authoring kit: 6 source-author guides, the `lint`/`improve`/`lower`/`decompose`/`review`/`promote` step guides, 6 authoring `persona-*` stances, 2 fragments): your skills dir (e.g. `.agents/skills/` or `.claude/skills/`), beside your own. Each carries its step *procedure* inline. (Code-implementation skills aren't here — they're Swarm-project reference.)
- Operative reference cards (the shared closed-set rules every step needs — SOL grammar, proofs/verdicts/adequacy, the structured form/edges): `.agents/reference/` (`sol.md`, `proofs.md`, `ir.md`). Load the card for the step you're running.
- Specs + intent: `specs/<feature>/` (the contract `spec.swarm.md` + its supporting docs co-located). Decisions: `decisions/` (numbered ADRs). Durable recall: `.agents/memory/` (`INDEX.md` is the load-*when* map).
- Project conventions (architecture boundaries, extra refusals, command bindings): in this file — see `## Project facts` and `## Commands` below.
- The **full** SOL/APS/steps manuals (rationale, worked examples) are **not installed** — they live in the Swarm project (`docs/`); the shipped cards carry the operative rules, the manuals carry the *why*.

## Compatibility
Swarm's skills install **directly into the dir your CLI scans** (`.claude/skills/` for Claude Code, or the
neutral `.agents/skills/`), beside your own skills — there is no separate home and no symlink bridge. Their
names (`pass-*`, `persona-*`, `write-*`) don't collide with yours, so an upgrade just re-copies them and
leaves your skills untouched. The reference cards sit in `.agents/reference/`.

## Commands
<!--
  The Commands contract. This is a FACT (a binding), which is why a table is allowed
  in an otherwise facts-only file. Each `cmd*` slot is the adapter a
  `VERIFY BY <type>:<adapter>:<artifact>` clause resolves through (the `verify` step; full reference in the Swarm project).

  NORMATIVE:
  - Populate a `cmd*` row for EVERY proof type any `VERIFY BY` clause in this repo references.
    An unresolved adapter is a verification-layer lint defect (SOL-V002) and a BLOCKED verdict
    at the gate; a missing required `cmd*` row is a negative validity-fixture class.
  - This is SOFT CONTROL: the table names what a future launcher WOULD run. Nothing here
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
