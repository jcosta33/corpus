# AGENTS.md — working on the Swarm framework

<!-- The always-loaded bootloader for an agent working ON this repo (the Swarm
     framework itself). Facts-only, ≤200 lines / 25 KB (the cap Swarm levies on its
     own AGENTS.md, §31.1). Procedures live in the skills under `.agents/skills/`. -->

## What this repo is

This repo **is** the Swarm framework — a markdown-only, provider-neutral, obligation-centered
specification compiler. It ships **no runtime**: every "parser/linter/planner/checker/CLI" is a
contract a future tool builds against, never code this repo runs.

- `docs/` — the self-standing framework (the product): `language/`, `model/`, `passes/`,
  `artifacts/`, `library/`, `reference/`, `research/`, `adrs/`, `examples/` + `PRINCIPLES.md`,
  `NON-GOALS.md`, `positioning.md`. The references here are complete; nothing defers to an
  external doc.
- `kernel/` — the installable payload a consuming repo adopts into `.swarm/kernel/`:
  `kernel/.agents/{language,templates,passes,skills,overlays,conformance,memory}` + `kernel/AGENTS.md`.
- `evals/` — rubrics.
- `.agents/` — this repo's agent-tool surface: `skills/` (the 34 skills, mirroring the kernel
  payload), `specs/swarm/` (the **frozen** build source), `audits/` (dev audits).

## Startup
1. Read the current task / request first.
2. Load only the skill, pass, or context file the task names (`.agents/skills/`); do not always-load.
3. Treat `.swarm.md` SOL blocks as authoritative over prose summaries.
4. Map every completion claim to evidence (paste real output; a claim without it is unverified).

## Universal rules (the conventions that keep this repo coherent)
- **Do NOT edit `.agents/specs/swarm/`.** It is the frozen build source — historical reference
  only. The shipped framework (`docs/` + `kernel/`) is the product and the source of truth; all
  changes go there (+ an ADR under `docs/adrs/`).
- **Keep the docs↔kernel twins in sync.** `docs/language/` ↔ `kernel/.agents/language/` and
  `docs/passes/` ↔ `kernel/.agents/passes/` are duplicate copies — a fix to one MUST be
  propagated to the other (the recurring "fix one, miss the twin" defect).
- **Evidence discipline (§0.7 — real science, not astrology).** Every load-bearing empirical
  claim cites a **verified** entry in `docs/research/sources.md`; non-peer-reviewed (caveated)
  sources never carry a `MUST`-level claim; a fabricated or misattributed source is never
  introduced. Web-verify a source (venue + finding) before grounding a claim on it.
- **Citations.** Framework-wide inline citations use `[[KEY]](…/research/sources.md#KEY)` and
  resolve to a real anchor in `docs/research/sources.md`. `docs/research/` is the cited corner;
  the rest of `docs/` carries no `.agents/specs` paths.
- **Original framework, not a migration.** Present Swarm as originally designed — no
  buffet / à-la-carte / "Earlier Swarm framing" / migration self-presentation. ADRs keep their
  supersession ledger (internal decision history) but neutral wording.
- **Self-standing.** `docs/` defers to no external or build-source document; `.agents/` is an
  agent-tool compatibility surface, never the canonical home of intent.
- **Carrier.** Skills ship as `SKILL.md` (discoverable, surgically `description`-activated), not
  `GUIDE.md`. Profiles are the `persona-*` skills under `skills/`; there is no `profiles/` dir.

## Canonical closed sets (counts MUST reconcile everywhere; hub: `docs/reference/flow-graph.md`)
- 7 block types · 5 modals · 7 verdicts (4 core + 3 lifecycle) · 9 proof types · 7 phases ·
  9 passes · 10 improve operations · 5 lint layers (S/P/M/V/O) · 7 edge types · 17 `task_kind` values.

## Pointers
- Skills (pass guides, per-kind implement, author, fragments, 13 personas): `.agents/skills/`
- Language reference (SOL / APS / errors / versioning): `docs/language/`
- The pipeline, artifacts, conformance: `docs/model/`, `docs/artifacts/`
- The evidence base (verified / caveated / rejected sources): `docs/research/sources.md`
- Architecture decisions (the ledger): `docs/adrs/README.md`
- Dev audits: `.agents/audits/`

## Commands
<!-- This repo is markdown-only and ships no build/test toolchain. There are no `cmd*`
     proof adapters to bind: the framework's own "obligations" are coherence properties,
     not code. Coherence is verified by deterministic checks an agent runs by hand —
     counts reconcile across docs, `[[KEY]]` citations resolve, internal links resolve,
     fences balanced, fixture JSON valid, no `GUIDE.md` / stale-structure refs — and by the
     conformance golden corpus under `kernel/.agents/conformance/fixtures/`. No runtime
     executes any of this (Invariant 1, NO RUNTIME). -->
| Slot | Command | Resolves |
| --- | --- | --- |
| — | (none shipped) | markdown-only repo; coherence checked by hand against the gates above |

## Workflow
- Work from `main`: commit and push directly to `main` (no branches/PRs).
- Commit messages end: `Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>`.

## Compatibility
`CLAUDE.md`, `GEMINI.md` (and peers) are symlinks to this file — one bootloader, many agent tools.
