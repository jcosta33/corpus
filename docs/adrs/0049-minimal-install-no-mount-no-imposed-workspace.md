---
type: adr
id: 0049-minimal-install-no-mount-no-imposed-workspace
status: accepted
created: 2026-06-06
updated: 2026-06-06
supersedes: 0045-overlays-are-project-owned, 0048-installed-payload-is-the-runtime-surface
superseded_by:
---

# ADR-0049: Minimal install — `.agents/`, no mount, a small flow-based folder set

> **Refined by [ADR-0050](./0050-swarm-is-a-spec-repo-discipline.md).** The goldilocks six-folder `.agents/`
> set below is the **spec repo's** authoring workspace. A **code repo** that only *consumes* specs gets
> near-zero — no specs, no SOL cards, at most one opt-in `implement-and-verify` skill, with all Swarm
> scratch gitignored. The per-repo version marker named here is **dropped** (see 0050 §6).

## Context

A pragmatic skeptic review of the adopted-project scaffold (grounded in what the shipped skills actually
reference) found most of the structure was ceremony a **no-runtime** framework cannot justify:

- **Empty filing cabinet.** Adoption pre-created ~32 `.gitkeep` directories (`sources/{10}`, `status/{4}`,
  `generated/{5}`, `memory/{2}`, `ledger/{3}`, `overlays/`, `archive/`, `tmp/`). Four of the eight
  top-level dirs (`status/`, `overlays/`, `archive/`, `tmp/`) are referenced by **zero** shipped skills or
  templates; the rest only by passing prose mentions. They are a filesystem for a runtime that does not
  exist — and Swarm's first invariant is that it ships **no runtime**.
- **The "kernel" mount + symlink bridge.** Skills were copied into a framework-owned `.swarm/kernel/skills/`
  and then surfaced into the agent's scan dir (`.claude/skills/`) by symlink. This was the source of **two**
  adoption bugs in a single session (a dir-symlink collision that hid the project's own skills, then a
  stranded skill). The structure manufactured the bugs.
- **"kernel" is empty jargon.** An OS kernel is a privileged runtime core; here the term named a folder of
  markdown. It borrowed authority it had not earned and appeared ~500× across the docs.

The skills are already self-contained ([0047](./0047-skills-are-self-contained.md)) and the shared rules
ship as compact reference cards ([0048](./0048-installed-payload-is-the-runtime-surface.md)'s Update). With
that, nothing requires a separate mount, a bridge, or a pre-built workspace tree.

## Decision

1. **Install is "copy files next to your skills."** Swarm ships three folders — `skills/`, `templates/`,
   `reference/`. An adopter copies them under `.agents/` (or, for a CLI that scans a fixed skills dir like
   Claude Code's `.claude/skills/`, puts the skills there directly). **No `.swarm/kernel/` mount, no symlink
   bridge.** Swarm's skills are ordinary skills, installed where skills live, beside the project's own.
2. **Upgrade is "re-copy the named files."** Swarm's skills carry recognizable names (`pass-*`, `persona-*`,
   `write-*`) that cannot collide with a project's own; an upgrade re-copies those, leaving the project's
   skills untouched. Replacement safety is a **naming** property, not a separate-mount property.
3. **A small, flow-based folder set under `.agents/` — the goldilocks middle** (see the Update below; this
   corrects the original "no folders at all"). Swarm prescribes **six** folders, every one of which the
   proven flow reads or durably writes — no more:

   | `.agents/` folder | Earned by |
   | --- | --- |
   | `skills/` | every pass loads its procedure here (install) |
   | `reference/` | the closed-set cards the skills name — `sol.md`/`proofs.md`/`ir.md` (install) |
   | `templates/` | artifact skeletons `author`/`implement`/`review` start from (install) |
   | `specs/` | `author` writes `*.swarm.md` sources; they need a home |
   | `tasks/` | `decompose`/`implement` task frames — **gitignored** (recreatable execution state) |
   | `memory/` | `promote` writes durable findings/patterns; `INDEX.md` is a required artifact |

   Other source artifacts (audits, findings, ADRs, PRDs…) are normal `type:`-tagged documents that live
   under `.agents/` however the project likes — **suggested, not mandated** (Swarm reads the frontmatter,
   not a fixed path). The adopted-kernel **version marker** lives in `.agents/` (e.g. `.agents/swarm.version`),
   not a `.swarm/` file. Anything that serves only a **future toolchain** — `status/` drift, `generated/`
   packets, an append-only `ledger/`, `archive/`, `tmp/`, the on-disk `.json` IR/plan files — is created
   **lazily, the first time a tool writes it**, never stamped empty at install. The test for prescribing a
   folder is "does a pass a human/agent runs **today** read or durably write it?"
4. **Project conventions live in `AGENTS.md`.** Architecture boundaries, extra refusals, and command
   bindings are project facts; they go in the bootloader an agent already reads first. There is no overlays
   directory (this is what supersedes [0045](./0045-overlays-are-project-owned.md)).
5. **"kernel" is retired everywhere** — adopter-facing *and* in the producer repo. It is OS-runtime jargon
   for a folder of markdown in a NO-RUNTIME framework. The concept is "the install" / "the installed files"
   / "Swarm ships X"; the producer directory `starter-kit/` is renamed `starter-kit/`. (The repo-wide text sweep is a
   tracked follow-up wave; this ADR fixes the decision.)

This **supersedes [0048](./0048-installed-payload-is-the-runtime-surface.md)** (the payload no longer mounts
at `.swarm/kernel/`; it installs in place) and **[0045](./0045-overlays-are-project-owned.md)** (no overlays
dir). It **refines [0040](./0040-kernel-payload-directory.md)** (the adopter-side mount it defined is gone;
the producer-side payload directory survives, rename pending) and **[0044](./0044-kernel-is-derived-and-self-contained.md)**
(`docs/` stays canonical and the derived files are still eyeball-diffed — they simply install in place
rather than into a mount).

## Alternatives considered

| Alternative | Why rejected |
| --- | --- |
| Keep the `.swarm/kernel/` mount + bridge | It exists only for wholesale replacement on upgrade, which unique skill names already give for free — and it caused two adoption bugs. Pure cost. |
| Prescribe **zero** folders (create everything on first write) | The original form of this ADR. Over-corrected: the proven flow genuinely needs homes for specs, tasks, and memory, and leaving them unprescribed makes adoption *less* intuitive and `promote`'s routing point nowhere. See the goldilocks Update below. |
| Keep the full pre-built workspace tree (~32 dirs) | The opposite extreme: 4 of 8 top-level dirs referenced by zero shipped skills; a filing cabinet for a runtime that isn't there. |
| Delete the reconciliation model entirely (status/generated/ledger as concepts) | That is design, not noise — the intent/reality/observed split and the surface policies are Swarm's value. The fix is to stop *materialising* them at install, not to remove them. They remain documented contracts a tool fulfils, created lazily. |

## Consequences

- **Positive:** adoption is "copy the install into `.agents/` and let six flow-based folders exist." No
  empty tree, no mount, no bridge, no OS jargon. The two classes of bridge bug become impossible, and the
  prescribed set matches how `.agents/` is already used in the wild.
- **Negative:** the elaborate `docs/model/workspace.md` filesystem model is replaced by a slim one, and the
  ADRs/docs that referenced `.swarm/kernel/`, the workspace tree, or overlays must be swept. Done as part of
  this change.
- **Neutral:** the obligation model, all closed sets, the SOL grammar, the pass pipeline, and the
  reconciliation *design* (desired/reality/observed, surface policies) are unchanged — only where files
  physically land changes.

## Update (goldilocks): a few prescribed folders, not zero

The first form of this decision swung to "no folders at all — create everything on first write." A
balanced review (flow → folder mapping; what's proven vs hypothetical) showed that over-corrected: the
proven flow genuinely needs homes for **specs**, **tasks**, and **memory**, and leaving them unprescribed
makes adoption *less* intuitive (a newcomer has nowhere obvious to put a spec) and leaves `promote`'s
routing table pointing nowhere. The correction is the **goldilocks middle** now in Decision §3: prescribe
the **six** `.agents/` folders the flow actually exercises, and only those — drop the ~26 dirs that served
a future toolchain. The principle is unchanged ("don't materialise what nothing reads"); the boundary moved
from *zero* to *the proven floor*. The review also caught a real defect: `conformance.md` required a
`.swarm/VERSION` file that no longer exists — the version marker moves to `.agents/`.

## Status

Accepted (v0.1), amended same-day to the goldilocks set (see Update). `docs/model/workspace.md`,
`docs/ADOPTING.md`, and the bootloader prescribe the six `.agents/` folders. Tracked follow-up waves: the
repo-wide `kernel`→`install` rename (incl. the producer dir + `CLAUDE.md`), the verbosity cuts (a concise
on-ramp; collapsing the three example walkthroughs; quarantining future-toolchain narration), and
reconciling README / PRINCIPLES / `conformance.md` with this model.

## Affected obligations / constraints

- Supersedes: [0045](./0045-overlays-are-project-owned.md), [0048](./0048-installed-payload-is-the-runtime-surface.md).
- Refines: [0040](./0040-kernel-payload-directory.md), [0044](./0044-kernel-is-derived-and-self-contained.md).
- Depends on: [0047](./0047-skills-are-self-contained.md) (self-contained skills make the in-place install safe).
- Does NOT change: the obligation grammar, any closed set, or the intent/reality/observed reconciliation design.
