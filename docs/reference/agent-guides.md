# Agent guides

_Works today — plain markdown plus your agent; no Corpus tooling required._

The guides are short procedural documents an agent CLI loads on demand (each ships as a
`SKILL.md`, auto-discoverable by agent tools and plainly readable by humans). They carry
procedure; the templates carry shape; this page is the index.

## Shipped in the kit (at `.agents/skills/`; tools discover them via symlinks like `.claude/skills`)

The core loop:

| Guide            | Use when                                                                                                                    |
| ---------------- | --------------------------------------------------------------------------------------------------------------------------- |
| `write-spec`     | turning a ticket/intake into a spec — intent not implementation, one behavior per requirement, every requirement verifiable |
| `implement-task` | executing a task packet — stay in scope, run every Verify item, paste real output, self-review the diff before handoff      |
| `review-output`  | filling a review packet — refute by default, re-run checks, evidence rules, route the exception triggers                    |

The workspace authoring guides, beside them:

| Guide                     | Use when                                                                                                                               |
| ------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| `write-audit`             | recording the present state of an area — observation only, evidence per finding                                                        |
| `write-inventory`         | mapping brownfield code before structural change — the contract map                                                                    |
| `write-change-plan`       | planning a refactor/rewrite/migration — baseline, preservation guarantees, waves, rollback                                             |
| `write-research`          | depth research on one question, against primary sources                                                                                |
| `write-bug-report`        | reproducing and root-causing a defect — diagnosis, never the fix                                                                       |
| `write-prd` / `write-rfc` | upstream intent and proposals                                                                                                          |
| `spec-check`              | running the checks of `checks.md` by hand                                                                                              |
| `split-work`              | partitioning a large change into parallel-safe tasks                                                                                   |
| `save-findings`           | the Close step — routing durable discoveries to findings                                                                               |
| `adversarial-review`      | a deep, hostile re-review of an agent branch — beyond the packet: re-run validation yourself, six adversarial questions, caller search |

## Optional (install from [the corpus-skills catalog](https://github.com/jcosta33/corpus-skills) when needed)

The catalog carries the **cross-cutting** conditioning stances — `persona-skeptic` (refute by
default; the lever is the checks you re-run), `persona-challenger` (pressure-testing a live proposal
before it is built), and `persona-surveyor` (breadth surveys across many examples) — plus the
standalone `empirical-proof` evidence discipline. The authoring stances (architect, auditor,
researcher, documentarian) are **not** shipped standalone: each lives folded into its work guide
(`write-spec`/`write-audit`/`write-research`/`write-documentation`), its single source
([ADR-0093](../adrs/0093-collapse-1to1-personas.md)). The catalog also carries long-form execution
guides per change shape (feature, fix, refactor,
rewrite, migration, performance, testing, documentation, flaky tests) plus
`implement-task` in long form. Install what your team uses with
`npx skills add jcosta33/corpus-skills` (add `--list` to preview without installing, or copy
the folders).

## Authoring your own guide

The kit's guides are conventions, and so is their shape — copy it when your team writes its
own:

- **Make the `description` directive.** Open with the verb of the work ("Implement…",
  "Review…"), say when the guide ALWAYS applies, name what it refuses to bypass, and end with
  a Skip clause that names **task types**, never sibling guide names — "skip for reviewing
  output", not "use review-output instead", so the description survives a renamed or absent
  sibling. Agent tools load guides by matching the description against the task, and directive
  phrasing is what gets a guide picked — observed in a self-published practitioner
  measurement, illustrative rather than proven
  [[ACTIVATION-BLOG]](../research/sources.md#ACTIVATION-BLOG).
- **Keep the body short; put depth one hop away.** A loaded guide is read whole — official
  guidance caps the useful body around 500 lines and moves detail into `references/` files
  loaded on demand [[SKILLBP]](../research/sources.md#SKILLBP).
- **Number the rules and attach the why.** A rule without its one-line rationale gets traded
  away under pressure. Add a Refuses table (temptation → do instead) — it catches the failure
  modes prose rules miss; the kit's core guides all carry one.
- **Make verification steps force output.** A step that says "verify X" invites a claim; a
  step that says "paste the output of X" produces evidence. End with a self-review gate the
  agent answers in writing.

## Load budget

Context is finite, and material buried in a long always-loaded context is reliably missed
[[LOSTMID]](../research/sources.md#LOSTMID) — so what loads, and when, is a design decision, not
an afterthought. Run a new or edited guide against this checklist (convention level):

- [ ] **The body is short.** It reads whole when loaded; depth lives one hop away in `references/`
      [[SKILLBP]](../research/sources.md#SKILLBP).
- [ ] **References are one hop away, not chained.** A guide points straight at the file it needs;
      it does not make the reader follow a chain of pointers to reach the procedure.
- [ ] **No hidden sibling-guide dependency.** A guide stands on its own — it never assumes another
      guide happens to be loaded. If it needs a concept a sibling owns, it names the concept, not
      "see the other guide" as a runtime requirement (the description's Skip clause names task
      types, never sibling names — see above).
- [ ] **The load trigger is exact.** The `description` says precisely when this guide fires, so the
      agent loads it when it applies and leaves it out when it does not.
- [ ] **The always-loaded bootloader stays small.** `AGENTS.md` is read on every turn; keep it a
      short index that points at guides and load-when state, not a manual.
- [ ] **No run logs in chat or always-loaded docs.** Store command output as an artifact and
      reference it; paste only the relevant lines into the review row that needs them. Externalizing
      state to files — rather than carrying it in context — is what makes multi-session agent work
      tractable [[CTXENG]](../research/sources.md#CTXENG). The load-when index in
      [memory.md](memory.md) is the mechanism for keeping that state findable.

Guides are conventions: they steer an agent, nothing enforces them. Review stances —
the cognitive postures the guides embed — are described in
[review-stances.md](review-stances.md).
