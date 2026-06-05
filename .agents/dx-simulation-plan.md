# Plan — Swarm developer-experience (DX), from simulation

> A **plan**, not changes. Method: instead of auditing the docs, **14 agents role-played the
> lived developer journey** end-to-end (adopt → ship → fix → audit → review → refactor → research,
> including running 3 agents concurrently and a red-teamer trying to break it), each reporting
> friction/successes as *experience*; every claimed gap was then **adversarially pressure-tested**
> against the real repo ("is this a real gap, or a mechanism the simulator missed?"); a synthesis
> built the prioritized plan from the confirmed-real gaps. Honors the hard constraints (markdown-only,
> **NO RUNTIME**, provider-neutral, the obligation/verification spine, ADR-0043 minimality, ADR-0044
> self-containment). Nothing here is applied yet.

## Executive summary

The **conceptual** layer is strong and first value *is* reachable — but the **operational adoption
bridge is thin, inconsistent, and undiscoverable**, and that single root cause produces the
highest-frequency, highest-severity findings (**9 of 14 journeys**). Concretely, verified against the
repo: there is no linked top-level quickstart; the only install steps (`kernel/README.md`, 4 numbered)
omit the `.swarm-version`→`.swarm/VERSION` rename, the 8-dir workspace `mkdir`, the memory seed-copy,
and the per-CLI skills bridge; the **always-loaded `kernel/AGENTS.md` pointer to `.swarm/memory/INDEX.md`
404s on a clean install**; and the **34 correctly-`description`-activated kernel skills install to
`.swarm/kernel/skills/`, off every agent CLI's discovery path, with no documented `.claude/skills`
wire — silently dead-on-arrival**, which is the load-bearing wire of the whole agents-as-compiler story.

Three more confirmed clusters: (2) the kernel **is not yet self-contained** — ADR-0044's K2 is
partially done (`AGENTS.md`/`conformance.yaml` are clean) but **359 dangling `§N` references and 3
`docs/` path leaks remain in the shipped skills/templates/fixtures** (this is the K2b work item), plus a
stale `docs/_legacy` adopting guide that misleads repo searches; (3) the **golden corpus contradicts its
own rules** — the `auth-refresh` `review.md` reaches a clean `PASS` while leaving a `gate:required`
interface unjudged (its own `SOL-V008`) and models the RISK-high-on-bare-test anti-pattern the adequacy
discipline forbids — so the oracle a future checker is validated against teaches the violation; (4) there
is **no solo/lightweight profile and no kernel-upgrade procedure**, so a one-file feature pays the full
nine-pass ceremony and every team improvises an unsafe payload swap that can clobber project overlays.

The good news: **nearly every high-value fix is fully NO-RUNTIME-compatible** (inert copy-paste text,
doc fixes, fixture corrections, and an *optional out-of-repo* reference checker the conformance corpus
was purpose-built to enable), and ADR-0043 already blesses the deterministic, subtractive direction.

## Cross-cutting themes (severity · journeys that hit it)

1. **No linked operational adoption path** — critical · 9. Conceptual model complete; install is thin,
   inconsistent (4 steps vs the arrow table), undiscoverable from the product entry point, never bridges
   concept → create-steps (mkdir the 8 dirs, seed memory, wire `.claude/skills`, rename `VERSION`).
2. **Skills dead-on-arrival** — critical · 3. 34 skills land off every CLI's discovery path; no bridge.
3. **Honor-system enforcement ceiling (NO RUNTIME + soft control)** — high · 8. Every gate is
   self-policed; fabricated traces, faked content-hashes, self-downgraded `QUESTION`s, green-only
   regression oracles, self-issued waivers, implementer==reviewer all pass undetected. *Mostly
   disclosed-by-design* (Invariant 2) — the cap on "endlessly robust" from inside the boundary.
4. **Kernel not yet self-contained** — high · 5. 359 dangling `§N` + 3 `docs/` leaks in shipped
   skills/templates/fixtures; the full 17-row conformance matrix + drift/staleness reference live only
   in un-installed `docs/`; `verify.md` points at a non-existent "drift pass".
5. **Golden-corpus inconsistencies** — high · 2. The validated oracle violates its own contract.
6. **No solo/lightweight profile, no upgrade procedure** — high · 4. Full ceremony for a one-file change;
   `overlays/` ships empty; the highest-stakes maintenance op (payload swap) has no recipe and overlays
   sit inside the framework-owned tree the swap replaces.
7. **Multi-agent coordination has the contract but not the composition** — high · 3. Disjointness,
   FORBIDDEN classification, liveness, merge-intent are specified-but-executor-deferred; **no artifact
   composes a conflict graph across N independent origins**, so disjointness reverts to the lead's
   eyeball — exactly where the model promised to abolish that. (The 3-concurrent-agents focus.)
8. **Workspace durable-record not materialized** — medium · 5. Install creates only `.swarm/kernel/`;
   the 8 canonical dirs ship no `.gitkeep`/`mkdir`, so empty durable-record dirs vanish from git,
   contradicting the framework's own "do NOT gitignore the durable record" promise.
9. **Discipline on the wrong side of a handoff** — medium · 4. `oracle_adequacy` lives in `verify` but
   is invisible to the implementer and absent from the trace template; the bug-report→fix carry-forward
   has no recipe; the "promote" verb is overloaded across pass-9, an improve op, and the audit→spec lift.
10. **Terminology/skeleton drift a markdown-only repo can't self-catch** — medium · 3. Four spellings of
    the scope-envelope field; two divergent memory `INDEX` seeds (one missing the rollback table); a
    missing `glossary.md` template twin; a dangling "drift pass" pointer; `bugs/` vs `bug-reports/`.

## The prioritized plan

| # | Title | Effort · Risk · Deps | The change |
| --- | --- | --- | --- |
| **P1** | One linked `ADOPTING.md` + a single canonical copy-paste install block | M · low · — | A `docs/ADOPTING.md` linked from both READMEs with ONE inert copy-paste shell block: copy payload → `.swarm/kernel/`; adopt `AGENTS.md` + the `CLAUDE.md`/`GEMINI.md` aliases; `.swarm-version`→`.swarm/VERSION` (+ de-dup the copy left in `kernel/`); `mkdir -p` the full 8-dir tree; seed `memory/INDEX.md`+`glossary.md`; build the project-owned skill home `.swarm/skills/` (symlink each kernel skill in from `.swarm/kernel/skills/`) and the provider bridges `.agents/skills`/`.claude/skills` → `.swarm/skills/` (see P2). Inert text, not a script (NO RUNTIME holds). Closes the top cluster in one artifact. |
| **P2** | Wire the skills bridge — **`.swarm/skills/` is the project-owned home; providers symlink to it** | S · low · P1 | Three tiers: (1) **`.swarm/kernel/skills/`** = shipped kernel skills, framework-owned, version-pinned, *replaced* on upgrade; (2) **`.swarm/skills/`** = the **project-owned** skill home that *survives* upgrades — the dev's own skills (real dirs) **plus** the kernel skills surfaced in by per-skill symlink (so a dev can keep their own conditioning separate from the shipped set); (3) provider bridges **`.agents/skills/`** (neutral 2026 cross-tool convention — Codex/Gemini discover it directly) and **`.claude/skills/`** (Claude Code scans its own dir) → symlink → `.swarm/skills/`. One funnel, both skill sets visible. Add a one-line pointer in `kernel/AGENTS.md` `## Compatibility`. Caveat: symlinks can break on Windows/`git` checkout — document a copy-with-resync fallback. Small model refinement (adds the project-owned tier): update `workspace.md` + the `AGENTS.md` compatibility wording + a one-paragraph ADR (refines 0040/0044). Un-bricks all 34 skills *and* gives the dev a private skill surface. |
| **P3** | Make the golden corpus self-consistent | M · med · — | Fix `auth-refresh` `review.md`: ship all 7 MUST sections, add the `IF-001` verdict (or demonstrate the BLOCKING `SOL-V008`), add a worked two-verdict example for the IR-split-vs-spec-id rule, add `cmdContract` to Commands/conformance, and add an `oracle_adequacy`/`V011` note (or re-bind off the bare test). The corpus is the tool-independent oracle — an internally-contradictory one teaches the violation. |
| **P4** | Complete ADR-0044 K2 (= **K2b**): make the shipped kernel resolve offline | L · med · — | Per-file `§`-rewrite/inline-or-drop for the remaining kernel files (decompose 75 / empirical-proof 61 / distillation 59 / review 49 / lint 48 lead the count); remove the 3 `docs/` leaks (`passes/implement.md`, `passes/verify.md`, `conformance/README.md`); install or inline the full 17-row suite + drift/staleness recipe; fix the `verify.md` "drift pass" pointer. Reference-resolution work, not a re-merge. |
| **P5** | A `covered-by` / optional-when-combined affordance on the Commands contract | M · med · — | Let one `cmd*` slot be declared covered by another (or mark `cmdFormat` optional-when-combined), so JS/TS repos whose tooling combines lint+format need not fabricate `cmdValidate`. Removes the structural pressure to author untruthful bindings — the root of the "schema-valid but untruthful" smell. |
| **P6** | `UPGRADING.md` + project-owned survival seams (overlays **and** skills) | M · low · P1,P2 | A preserve-list + safe-replace sequence + post-upgrade re-grade checklist. Two project-owned things must survive the `.swarm/kernel/` swap: (a) **overlays** — relocate to a sibling `.swarm/overlays/` (or mark project-owned-preserve with stash/restore); (b) **`.swarm/skills/`** — leave the dev's real skill dirs untouched and **re-sync the kernel→`.swarm/skills/` symlinks** (add new kernel skills, prune removed ones). The ownership boundary (`.swarm/kernel/` framework-owned vs `.swarm/skills/` + `.swarm/overlays/` project-owned) is what makes the upgrade safe. |
| **P7** | A solo / lightweight execution profile (overlay) | M · med · — | A `solo-feature` overlay under `kernel/.agents/overlays/` marking the fan-out artifacts (`plan.json`, coordination record) skippable for n=1, documenting a "straight from IR to one `task.md`" route, and naming which hand-fields are optional until a compiler ships. Uses the existing (empty) overlay mechanism — no new construct. |
| **P8** | Surface oracle-adequacy where the work is conditioned | M · low · P3 | Add the 4 `oracle_adequacy` placeholder fields to `templates/trace.md`; a one-line cross-link in `write-refactor/SKILL.md` to the `verify` adequacy section; a vocabulary→enum bridge in `proof-types.md`; and one `refactor-*` golden fixture (property/differential oracle, filled adequacy). One root cause, four gaps; the fixture erases three at once. |
| **P9** | Resolve the "promote" verb overload + the no-obligation fix lane | S · low · — | Audit-completion signpost in `write-audit/SKILL.md` ("to act on an audit, re-run `write-spec` as a parent"); a named carry-forward recipe in `write-bug-report/SKILL.md`; a sanctioned no-covering-obligation fix path in `write-fix`. Cheap signposting for the most load-bearing transition (observation→intent→action). |
| **P10** | An **optional, out-of-repo** reference checker for the lexical/structural subset | XL · high · P3,P4 | A ~200-line dependency-free checker **in a separate repo** that reads `conformance.yaml` and runs the deterministic lexical/structural + count-reconciliation + glob-overlap checks (reject bare "tests passed", REQ-in-audit, two same-surface packets both `merge_safe`, missing review sections, AGENTS.md over-cap). Built *against* the contract, explicitly **not** framework runtime — ADR-0043 blesses this. Highest-leverage move on the "rough" enforcement rating; everything upstream was purpose-built for it. |
| **P11** | A runtime-resource field + a cross-IR run-board for concurrent multi-origin work | L · med · — | Add a "shared runtime resource" column to the `task-orchestration.md` worker tracker and the `task.md` Parent contract; a blessed multi-origin run-board (`sources:[]` frontmatter); document the per-CLI worktree launch ceremony; widen `persona-lead-engineer` "Applies when" to N-origin coordination. The glob-lattice safety primitive already transfers across origins — this is composition + a tracker field, not new semantics. (The 3-concurrent-agents ask.) |
| **P12** | Decluttering + consistency sweep | M · low · P4 | Delete/`SUPERSEDED`-stamp the stale `_legacy` adopting/quickstart/monorepo guides (promoting the still-valid nested-`AGENTS.md` monorepo convention into current docs); unify the 4 spellings of the scope-envelope field to one canonical name; collapse to one canonical 6-section memory `INDEX` skeleton; add the `glossary.md` template twin; fix the `bugs/` vs `bug-reports/` contract outlier; fix the dangling "drift pass" pointer. |
| **P13** | Decide `SOL-V011` default polarity for RISK-critical (ADR) | S · med · P3,P8 | An ADR: make oracle-adequacy **BLOCKING-by-default for RISK critical** (and maybe high), or ship strict-mode pre-enabled in the kernel seed. The safe default is currently inverted relative to consequence at the highest-stakes obligations. ADR-level (changes a closed-set severity default). |
| **P14** | By-hand rituals for the deferred-runtime gates | M · low · — | A named "drift sweep" ritual in `promote`/`review` (re-read each required binding's recorded surfaces before close; a convention for `content_hash` when no hasher ships, so devs stop pasting fakes that make every `PASS` look fresh forever); an inert `wc`-based snippet (or an over-cap negative fixture) for the AGENTS.md cap MUST; an obligation-debt backlog convention so a `deferred` coverage gap resurfaces. |

### Quick wins (cheap, high-value, do-first)

- Retarget the `kernel/AGENTS.md` memory pointer to `.swarm/kernel/memory/INDEX.md` (where the seed
  actually ships) **or** add a seed-copy step — kills the dangling always-loaded pointer (part of P1).
- Fix the `bugs/` vs `bug-reports/` divergence by editing the single outlier `docs/artifacts/bug-report.md:31`
  to match the five guides (`sources/bugs/`) — one-line contract correctness (part of P12).
- Add the `.claude/skills` bridge command + the `kernel/AGENTS.md` `## Compatibility` pointer (P2).
- Add the `.swarm-version`→`VERSION` rename + de-dup to the numbered Adopting steps (today only in the
  arrow table) — removes the step/table inconsistency (part of P1).
- Audit-completion signpost in `write-audit/SKILL.md` (part of P9).
- Add the 11 required H2 sections (or a cross-ref) to the `SOL-S012` catalogue entry so a first-time
  hand-linter can self-verify which sections a spec needs.
- Delete/`SUPERSEDED`-stamp `docs/_legacy/guides/adopting-swarm.md` so a search for "adopting" no longer
  lands on `/scaffold/`-era instructions (part of P12).

## Honest caveats (the §0.7 / NO-RUNTIME line)

- **NO RUNTIME forbids an executable installer/checker *in this repo*, but not inert copy-paste text nor
  an optional checker that lives in a separate repo** and builds against the conformance contract. So the
  highest-value adoption fixes are invariant-compatible; the honest residual limit is that none can *run*
  from here, and an adopter who skips a manual step still gets a silently-broken setup with no signal.
- **The deepest DX ceiling is structural and by-design.** Every gate (disjointness, COVERAGE, merge,
  BLOCKED-vs-PASS, regression-oracle, oracle adequacy, implementer≠reviewer) is honor-system; a fabricated
  trace is byte-indistinguishable from a real one. The framework specifies the *correct* behavior but
  can't mechanically enforce it (Invariant 2). This caps how "endlessly robust/safe" it can be from
  inside its own boundary — a disclosed limit, not a defect.
- **Do NOT chase these "safety gaps"** — acting on them would mean shipping a runtime or a composition
  police the framework explicitly forbids: the soft-control non-enforcement of `AGENTS.md`; the
  unfilled-`Commands`-placeholder and dangling-`VERIFY BY`-artifact (already `SOL-V002` BLOCKING); the
  REQ-block-in-an-audit boundary (deliberately un-policed per ADR §17/§26.1); the `.swarm.` infix as the
  sole discriminator. The right response is the honest disclosure that already exists.
- **A genuine "simpler vs safe" tension** sits in P5: relaxing required command slots makes adoption
  truthful and frictionless but widens the door to an under-declaring `Commands` table. The current
  over-requiring is itself the *cause* of the fabrication smell, so the trade favors honesty — but it is
  a real trade, not a free win.
- **The agents-as-compiler activation gap markdown alone can't fully close:** the strongest controls
  (`empirical-proof`, `persona-skeptic`) only bite if *loaded*, and load-on-demand means the implementer
  decides whether to summon the reviewer that would catch the implementer. Description-driven activation
  (P2) mitigates; the always-loaded `AGENTS.md` "no completion without evidence" is the only floor, and
  it is soft. A hard guarantee is out of scope without a runtime.

## Relationship to existing work

- **P4 *is* K2b** (the already-queued remainder of ADR-0044) — the simulation independently confirms it
  with a count (359 refs) and the 3 `docs/` leaks; promote it to the front of the kernel-self-containment
  work. **P12** overlaps it (the `_legacy` + drift-pointer cleanup).
- **P10** is the concrete realization of the deterministic-external-check spine ADR-0043 blessed — and
  the natural home for the lint/provenance/staleness checks from the `lintable-docs-improvement-plan`.
- **P7/P11** extend the kernel-payload model (ADR-0040/0044) with the solo overlay and the multi-origin
  run-board; **P13** is a new ADR (closed-set severity default).

## Suggested sequencing

1. **The adoption bridge** (P1 + P2 + the quick wins) — closes the critical cluster, low risk, unblocks
   everything a real adopter does first.
2. **Self-containment + corpus integrity** (P4/K2b + P3 + P12) — makes the installed product correct and
   the oracle trustworthy; P3 gates P8/P10/P13.
3. **The pipeline-ergonomics + safety items** (P5, P6, P7, P8, P9, P11, P14) — the per-journey QOL fixes.
4. **P13** (the ADR) and **P10** (the optional external checker) last — the design decision and the
   biggest, separable build.

---

*No framework changes made. Method: 14 lived-journey simulations + per-journey adversarial pressure-test
+ synthesis (workflow `wng3557dx`, 29 agents). Every plan item is built from a pressure-test-confirmed
real gap; the honest_caveats record where the no-runtime nature limits DX. Execution awaits review.*
