---
type: change-plan
id: CHANGE-dx-formats
title: Amend the frozen artifact formats the DX audit faulted
status: done
kind: schema-change
owner: José Costa
sources: [SPEC-dx-remediation, .agents/audits/dx-audit-2026-06-12.md]
preserves: [PG-001, PG-002, PG-003, PG-004, PG-005, PG-006, PG-007, PG-008]
created: 2026-06-12
---

# Change Plan: Amend the frozen artifact formats the DX audit faulted

## Intent

Change the kit's frozen formats — task packet, review packet, status board, intake, finding
and spec templates, the Commands table, the seed ADR, the kit example chain, three advanced
cards, and the checks contract — to close the format-cluster requirements of
`SPEC-dx-remediation` (**AC-001/002/003, 004, 011, 012, 014–020, 033, 035, 037–042, 044, 045,
048**), while every behavior the rest of the framework depends on provably survives.

## Why this change is needed

The DX audit's highest-confidence finding (9 of 11 personas, 7 MAJOR) is that the run summary
— demanded by every surface, called the raw material of the Evidence column — has no home in
any format. The same audit faulted the Pass-evidence rule's CLI-only form (restated on ~14
surfaces), the Commands table (4 personas), the board's missing blocked state (2),
tracker-only intake shapes (2), the missing reviewer field, and contract drift inside checks/.
These are public interfaces of the kit: every adopter workspace, all three examples, the
checks fixtures, and a dozen guides restate them, so the change must be sequenced, not
sprinkled. The challenge round added the sustainability transformation (AC-044: the session
maintains the board) — the only fix that attacks the audit's unanimous 3.0 floor.

## Baseline

Per the audit's verified register and the formats as committed at `dc10f39`:

- `templates/` holds exactly eight files: `change-plan.md finding.md intake.md inventory.md
  review.md spec.md status.md task.md`.
- `templates/task.md` sections: Source · Scope · Do not change · Affected areas · Verify ·
  Agent instructions · Findings — no run-summary home; `checks/checks.yaml` v0.3.0 pins the
  same `required_sections` and declares no task status enum.
- The Pass-evidence rule reads "pasted output or a CI link" — no manual-method clause — on
  every restating surface (docs/01/02/06/08, review template comment, checks.yaml
  `pass-needs-evidence`, cheatsheet ×2, artifact-formats, principles, step-bars ×2, kit
  checks-reference, kit review-output guide, seed ADR, large-pr-review example).
- `templates/review.md` frontmatter: `type, id, task, pr, status` — no `reviewer:` field;
  status enum draft | pass | blocked | needs-human; results Pass · Fail · Unverified ·
  Blocked; no waiver record or terminal merged-with-waiver status; no stated home for non-AC
  Verify results; spot-check exists only as a comment, leaving no trace when performed.
- `templates/status.md` task-row vocabulary: ready / running / review-ready / closed — no
  blocked, no review example row; the shipped root `status.md` carries `{{slug}}` placeholder
  rows; nothing anywhere states who maintains the board.
- `templates/intake.md` source examples: tracker shapes only. `templates/finding.md` origin
  hint: task/review ids only. `templates/spec.md` carries the stale "copy it in" notation
  note. `starter-kit/examples/feature-from-ticket/task.md` has no run summary.
- `starter-kit/AGENTS.md` Commands table: four app-shaped slots, one command per kind, no
  multi-context convention, no slot-set pointer; the seed ADR states the evidence rule in the
  CLI-only form.
- `checks/README.md` cites REFLEXION where docs/reference/checks.md cites EVIBOUND, and tells
  a checker it may "implement the checks reference directly — they must agree" without scoping
  out the SOL catalogue; checks.yaml's header makes the unscoped shadow claim and states no
  frontmatter-list semantics; the adversarial-review task template calls cmd-prefixed values
  non-contract; `advanced/threat-model.md` repeats a cross-reference on one line.

## Target state

- `templates/task.md` carries `## Run summary` as the **handoff digest** (changed files ·
  per-command result digest citing the Verify pastes · out-of-scope edits · blocked questions
  · finding-candidate notes); the Verify section stays the single evidence home, and
  checks.yaml's prose notes the summary cites, never replaces (the `non-empty-paste` rule's
  `applies_to` stays Verify). checks.yaml v0.4.0 adds the section to `required_sections`,
  declares the task status enum (the existing four values), scopes its shadow claim to the
  core checks, and states its frontmatter-list semantics (extra keys legal); fixtures pin all
  of it (conformant-task gains the section; one new negative fixture: summary missing at
  `closed`).
- The Pass-evidence sentence is amended **once** — "pasted output, a CI link, or, for a manual
  Verify method, a named human's recorded observation" — and every restating surface carries
  the amended form (AC-003's enumerated sweep).
- `templates/review.md` gains `reviewer:`, the `Spot-checked:` line, and the waiver record
  (who · which rows · why · expiry) with the terminal merged-with-waiver packet status per
  Q1's recommended resolution — all template-carried; only the status-enum value touches the
  contract. Row results stay the four values.
- Board task vocabulary gains blocked as board-only state (the spec-row precedent), a review
  example row is seeded, root `status.md` ships with a comment-only example row, and the kit
  AGENTS.md closing instruction makes the finishing session flip its board row (AC-044).
- Intake source examples include `gh-pr` and an informal channel; the finding origin hint
  accepts `AUDIT-*`/`INV-*`; the spec template's notation note is current; the kit example
  chain shows the Run summary.
- The Commands block documents dispatcher-first, then per-context sub-tables (canonical slot
  names, context in the heading, one resolution line) and one pointer line naming the
  remaining contract slots — no new slot-name grammar, no empty placeholder rows.
- checks/README cites EVIBOUND and scopes its agreement claim (core checks; SOL catalogue is
  prose-only); no kit card calls a cmd-prefixed value non-contract.
- **Explicitly unchanged:** the eight-template set and filenames, every existing enum value
  (additions only), the two PG-001-protected evidence texts, the kit's symlink topology, the
  requirement-id scheme, the result enum (Pass · Fail · Unverified · Blocked — closed).

## Behavioral preservation guarantees

| ID | Behavior | Verify with |
|---|---|---|
| PG-001 | Two evidence texts survive verbatim: the task-side `non-empty-paste` rule text and "an empty Evidence cell means **Unverified**, never **Pass**" (the review-side Pass sentence is deliberately amended by AC-003 — it is NOT protected) | per surface: `diff <(git show dc10f39:F \| grep -i 'unverified, never') <(grep -i 'unverified, never' F)` empty for checks.yaml, docs/08, review template; checks.yaml's non-empty-paste rule block unchanged except the cites-not-replaces comment |
| PG-002 | The template set stays exactly these eight files: change-plan.md, finding.md, intake.md, inventory.md, review.md, spec.md, status.md, task.md | `ls starter-kit/templates \| sort` equals exactly that list |
| PG-003 | Every existing enum value survives in its declaring line — additive changes only | `fail=0; for v in draft pass blocked needs-human ready running review-ready closed Pass Fail Unverified Blocked; do grep -rqw "$v" starter-kit/templates checks/checks.yaml \|\| { echo "MISSING $v"; fail=1; }; done; [ $fail -eq 0 ]` — prints nothing; plus eyeball of the four declaring lines (review status_enum, result_enum, board task row, board spec row): old values all present |
| PG-004 | The counts registry's two-home rule holds: any enum/section change updates checks/README.md and the cheatsheet appendix in the same commit as the fixtures | wave-2 commit's `git show --stat` includes both homes; counts-leakage grep returns 0 |
| PG-005 | Kit self-containment: no kit file links into docs/ | `grep -rn '](\.\./docs\|](docs/' starter-kit --include='*.md'` returns nothing |
| PG-006 | The kit's symlink topology is unchanged: exactly `CLAUDE.md→AGENTS.md`, `GEMINI.md→AGENTS.md`, `.claude/skills→../.agents/skills` | `find starter-kit -type l` lists exactly those three with those targets |
| PG-007 | v0.3.0 → v0.4.0 contract deltas are exactly the enumerated set: (a) task `required_sections` + Run summary; (b) task `status_enum` declaration (existing four values); (c) review `status_enum` + the one additive terminal value (Q1); (d) the `pass-needs-evidence` rule's manual-method clause (a relaxation — old packets still conform); (e) the shadow-scope + frontmatter-semantics + cites-not-replaces comments. An old task packet fails only on the missing Run summary; an old review packet does not fail at all | `git diff dc10f39 -- checks/checks.yaml` hunks map 1:1 onto (a)–(e); reviewer signs the mapping in the wave-2 packet |
| PG-008 | README stays ≤120 lines and user-tier vocabulary tiers hold across every touched page | `wc -l README.md` ≤ 120; tier banned-token greps return 0 |

## Non-goals

- The pure-doc requirements of SPEC-dx-remediation — **AC-005–010, 013, 021–032, 034, 036,
  043, 046, 047, 049–052** — cut directly from the spec as plain tasks. Where one lands on a
  file a wave already edits (AC-050 on the wave-4 example; AC-046 on wave-3's docs/07), batch
  it into that wave's task to avoid double edits — scope listed per task, never implicit.
- No SOL grammar or catalogue changes (AC-040 scopes the claim, it does not extend the yaml);
  no new slot-name grammar (Q3's resolution is contract-neutral).
- No new coverage-row result values — the waiver lands as a record plus a packet status, never
  a row Result.
- No future-cli contract changes beyond the checks.yaml version bump; no swarm-cli work (its
  resync stays separately owned and retargets v0.4.0 at cutover).

## Affected surfaces

| Surface | Intended change |
|---|---|
| `docs/adrs/0072-*.md` (new) | format amendments; Q1–Q3 resolutions; **partial supersession of ADR-0060's addendum** (run record folds into the review packet — reversed by AC-001) |
| `starter-kit/templates/task.md` | + `## Run summary` digest section (AC-001) |
| `starter-kit/templates/review.md` | + `reviewer:`; waiver record + terminal status per Q1; non-AC results note; `Spot-checked:` line (AC-014/015/016/045) |
| `starter-kit/templates/status.md` | task-row blocked (board-only) + review example row (AC-017) |
| `starter-kit/templates/intake.md` | source examples gain gh-pr + informal channel (AC-011) |
| `starter-kit/templates/finding.md` | origin hint accepts AUDIT-/INV- (AC-035) |
| `starter-kit/templates/spec.md` | stale "copy it in" note removed (AC-042) |
| `starter-kit/AGENTS.md` | Commands: dispatcher-first + sub-table convention + slot-set pointer line; closing instruction flips the board row (AC-019/020/044) |
| `starter-kit/status.md` | comment-only example row, no placeholders (AC-018) |
| `starter-kit/decisions/0001-adopt-swarm.md` | evidence sentence in the amended AC-003 form (AC-004) |
| `starter-kit/examples/feature-from-ticket/` | task.md gains the Run summary; chain stays consistent (AC-002) |
| `starter-kit/advanced/checks-reference.md` | amended Pass sentence (AC-003 sweep) |
| `starter-kit/advanced/threat-model.md` | duplicated cross-reference removed (AC-041) |
| `starter-kit/advanced/adversarial-review/references/task-template.md` | no cmd-prefixed non-contract values (AC-039) |
| `starter-kit/advanced/split-work/SKILL.md` | platform carve-out + coverage semantics (AC-012) |
| `checks/checks.yaml` | v0.4.0: deltas (a)–(e) of PG-007 (AC-001/003/038/040/048 + Q1) |
| `checks/fixtures/*` | conformant-task gains the section; one new negative fixture; EXPECTED pins |
| `checks/README.md` | EVIBOUND citation; agreement claim scoped; counts updated (AC-037/040) |
| `docs/01/02/06/07/08/09 + reference/{artifact-formats,cheatsheet,glossary,step-bars,principles,advanced-lifecycle}` | amended formats + evidence-sentence sweep + run-summary home + V4 waiver clause + platform carve-out restatements (AC-002/003/012/014) |
| `docs/examples/*` (all three) | re-cut: Run summary shown; staging path demonstrated; arithmetic recounted (AC-002/033) |
| kit + library guides (`implement-task`, `review-output`) + `.agents/skills/` mirrors | amended formats + board-flip checklist item (AC-002/044) |

## Risk areas

- **Two paste homes** — the rejected failure mode AC-001's digest semantics exist to prevent;
  wave-2 review checks no surface tells the agent to paste output into the summary.
- **Enum/sentence drift** — the C004 class: a value or the amended Pass sentence updated on
  N−1 of its restating surfaces. AC-003's sweep list and AC-012/014's surface lists are
  enumerated up front; the wave verify greps the full lists.
- **Examples arithmetic** — three long walkthroughs get re-cut; both prior reviews found
  counting errors in exactly these files.
- **Vocabulary tier leakage** — the Q1 record lands in user-tier words (who waived, why,
  until when); Waived-the-annotation stays reference-tier; the glossary carries the mapping.
- **Same-commit rule** — wave 2 must land templates + checks.yaml + fixtures + both count
  homes in one commit, or the contract and its oracle disagree in history.
- **Gate freshness** — every spec AC gate was pre-flighted failing; re-run the pre-flight
  before wave 2 so no gate has gone vacuously green under interim commits.

## Transformation waves

Schema-change note: the guide mandates expand → migrate → contract with a bridge release where
external consumers exist. **There are none pre-launch** (the only consumer, swarm-cli, is
paused pending resync), so expand and contract collapse into the formats wave (wave 2) as a
recorded flag-day — the version bump is the compatibility marker, and PG-007 bounds the blast
radius to its enumerated deltas.

1. **Decide** — write ADR-0072: the format amendments, the Q1–Q3 resolutions (recommended
   forms recorded in the spec's Open questions), and the partial supersession of ADR-0060's
   run-record addendum; ledger row; SPEC-dx-remediation's open questions close and the spec
   flips to `ready`.
   *Verify:* ledger gates (link resolver, row present); spec status `ready` with no blocking
   open question.
2. **Formats + contract (one commit)** — every `starter-kit/` surface in the table above
   except split-work, checks.yaml 0.4.0 (deltas (a)–(e)), fixtures incl. the new negative
   fixture, checks/README + cheatsheet count homes.
   *Verify:* ruby YAML parse pasted; fixture↔contract greps; spec gates AC-001, 003 (kit/
   contract surfaces), 004, 011, 014–018, 019, 020, 035, 037–042, 044 (kit half), 045, 048
   run and pasted; PG-001…PG-008 run and pasted.
3. **Docs propagation** — happy path + reference pages: the evidence-sentence sweep completes
   (AC-003), the run-summary home lands on the instructing doc surfaces (AC-002), the V4
   waiver clause (AC-014), the platform restatements (AC-012), glossary mapping.
   *Verify:* AC-003 full sweep grep returns nothing; AC-002 grep clean over its docs surfaces;
   link resolver; tier greps (PG-008); citation-anchor check.
4. **Examples re-cut** — all three walkthroughs plus the kit example chain show the Run
   summary digest and the Findings staging; arithmetic re-counted against their own tables.
   (AC-050's demo pointer batches here as a spec task on the same file.)
   *Verify:* AC-033 five-surface grep clean; AC-002 example surfaces clean; per-example
   recount pasted; link resolver.
5. **Guides + dev subset** — kit/library implement-task and review-output (run-summary home,
   board-flip checklist item), split-work (AC-012), mirrored dev skills.
   *Verify:* AC-002 full grep returns nothing (the cutover form); AC-012 three-surface gate;
   AC-044 guide half; kit self-containment grep (PG-005).

Each wave is one commit on `main` (producer convention); a wave's gates run before the next
wave starts. No shims: markdown formats forward old → new by re-edit, not by bridge files.

## Cutover conditions

- All five waves green with pasted gate output; PG-001…PG-008 verified in the final state.
- Every plan-scoped AC gate (AC-001/002/003, 004, 011, 012, 014–020, 033, 035, 037–042, 044,
  045, 048) passes its Verify-with line — none was green at baseline.
- Adversarial self-review (ADR-0056) of the whole landing recorded; the swarm-cli resync
  backlog retargets checks.yaml v0.4.0.

## Rollback criteria

- Any gate red after its wave's commit → `git revert` that wave (each wave is one commit).
- A contradiction discovered between checks.yaml 0.4.0 and any fixture after wave 2 → halt
  waves 3–5, fix or revert wave 2 first; the contract and its oracle never disagree across
  waves.
- Q1's terminal status turns out to demand renaming an existing status value, or any answer
  forces a rename anywhere → stop; that exits PG-003's additive-only envelope and needs a
  superseding plan.

## Verification strategy

- [ ] `ruby -ryaml` parse of checks.yaml after every wave that touches it
- [ ] PG-001…PG-008 commands, run and pasted per wave that could move them
- [ ] Plan-scoped AC Verify-with lines, run at their landing wave and again at cutover
- [ ] The repo gate set per wave: link resolver · citation anchors · tier/banned-token greps ·
      counts-leakage · kit self-containment · symlink census · README line budget

## Review focus

- Wave 2's single commit: did templates, contract, fixtures, and both count homes really move
  together? (`git show --stat`)
- The digest rule held: no surface instructs pasting command output into the Run summary.
- The AC-003 sweep: hunt the one restating surface the list missed (the C004 failure class).
- The three examples' recounts — verify the arithmetic against the tables, not the prose.
- Q1's landing: user-tier words on user-tier pages; the glossary mapping present; PG-007's
  delta (c) is additive and nothing else moved in review_file.
- The reviewer and Spot-checked fields stayed OUT of the contract's required frontmatter.

## Task split

| Task | Wave | Scope (guarantee/requirement ids) |
|---|---|---|
| TASK-dx-fmt-w1 | 1 | ADR-0072; closes Q1–Q3; records the ADR-0060 addendum supersession |
| TASK-dx-fmt-w2 | 2 | implement AC-001, 003 (kit/contract surfaces), 004, 011, 014, 015, 016, 017, 018, 019, 020, 035, 037, 038, 039, 040, 041, 042, 044 (kit half), 045, 048 · preserve PG-001–PG-008 |
| TASK-dx-fmt-w3 | 3 | implement AC-002 (docs), 003 (docs sweep), 012 (reference restatements), 014 (docs/08 + step-bars V4) · preserve PG-001, PG-004, PG-008 |
| TASK-dx-fmt-w4 | 4 | implement AC-002 (examples + kit example), AC-033 · batch AC-050 · preserve PG-008 |
| TASK-dx-fmt-w5 | 5 | implement AC-002 (guides), AC-012 (split-work), AC-044 (guide half) · preserve PG-005, PG-008 |

> **Landed (2026-06-12):** waves 1–5 complete, each one commit on `main` (ADR-0072 → formats +
> contract → docs → examples → guides + dev subset). Cutover battery pasted in the landing
> session: all 24 plan-scoped AC gates PASS; PG-001 verified at the parsed level (rule text
> byte-identical), PG-002/003/005/006/008 green, PG-004 trivially held (no registered count
> changed), PG-007 diff mapped 1:1 onto deltas (a)–(e) at wave 2. Adversarial self-review:
> no stale-wording remnants ("Leave a summary", "left in the PR description" — zero hits),
> kit AGENTS.md at 70 lines (~100 budget), no reference-tier lifecycle vocabulary on user-tier
> pages, links/anchors clean. The swarm-cli resync (separately owned) retargets checks.yaml
> v0.4.0. The non-format spec ACs (the wave-batched doc tasks) all verified green in waves
> 3–5; SPEC-dx-remediation's full gate set is satisfied except AC-043's manual side-by-side
> check, recorded here: kit review-output rule 2–4 and docs/08's rules now state one bar
> (amended Pass sentence, re-run what you can, spot-check one green row) — judged by the
> landing session's author, so a fresh-session reviewer should re-judge it at the next review.
