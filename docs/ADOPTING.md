# Adopting Swarm

Swarm lives in a **spec / documentation repo** — that's where intent is authored and reviewed. **Code repos
stay pristine**: a great SOL spec is self-legible, so a developer's repo needs essentially nothing from
Swarm. Adoption is **handing your coding agent the `starter-kit/` folder** and asking it to integrate the
*right subset* for the repo's role. There is no installer (NO RUNTIME) — just files an agent places,
adapting to how your repo is already laid out.

## Which role is this repo?

- **Spec / docs repo** — authors and reviews specs. Takes the **authoring kit**. ([§ Spec repo](#spec-repo))
- **Code repo** — implements against specs. Stays pristine; takes at most the tiny **implementing kit**.
  ([§ Code repo](#code-repo))
- **Co-located** (solo / single repo) — one repo does both: follow *both* sections. The degenerate case,
  and the right choice when you don't have (or want) a separate spec repo.

One spec can govern **many** code repos: obligations carry namespaced ids and SOL has cross-spec references
(`spec-id#AC-001`), so a code repo's PR names the obligation it satisfies in the central spec.

## <a id="spec-repo"></a>Spec / docs repo — the authoring kit

Point your agent at a checkout of this repo and say:

> Adopt **Swarm (authoring)** into this repository. Read `<swarm-repo>/starter-kit/` and integrate it,
> following `<swarm-repo>/docs/ADOPTING.md`:
> - Place `starter-kit/.agents/{skills,reference,templates}` under `.agents/` (skills go in whatever dir my
>   agent CLI scans — `.claude/skills/` for Claude Code, else `.agents/skills/` — beside my own).
> - Adopt `starter-kit/AGENTS.md` as my root `AGENTS.md` (+ `CLAUDE.md`/`GEMINI.md` `@AGENTS.md` aliases);
>   **merge** if one exists. Fill `## Commands` and `## Project facts`.
> - Specs (`*.swarm.md`) live in `.agents/specs/`; other intent docs (PRDs, RFCs, ADRs, audits, findings)
>   are `type:`-tagged docs under `.agents/`; `.agents/memory/` holds durable recall. Reuse my existing
>   layout where I have one. Report what you placed and merged.

Here the full flow runs — `author → lint → improve → review` to produce a trustworthy spec, and optionally
`lower → decompose` to ship a **parallel-safe plan** (which obligations are write-disjoint) that developers
hand to agents in worktrees.

## <a id="code-repo"></a>Code repo — pristine

A code repo needs **nothing required**. Don't add SOL reference cards or specs — the spec (delivered, or
referenced by id from the spec repo) is the whole interface. The most you adopt:

> Adopt **Swarm (implementing)** — minimally. From `<swarm-repo>/starter-kit/`:
> - Optionally copy the one skill `.agents/skills/implement-and-verify/` into my skills dir (the trust
>   backbone for running agents in parallel worktrees). Optionally a `persona-*` I like.
> - Append `starter-kit/.gitignore.additions` to my `.gitignore` so Swarm scratch (task frames) never lands.
> - Nothing else: no specs, no reference cards, no version file, no `.swarm/`.

When implementing: the agent reads the obligation, implements only it, proves each with its `VERIFY BY`, and
opens a **PR that names the obligation ids** — the PR + CI + review *are* the trace and verdict. Anything
durable (a learning, a decision, discovered drift) goes **back to the spec repo as a linked PR**, never as a
file in the code repo. (A structured `trace.md`/`review.md` in the code repo is opt-in, for audit/compliance.)

## Brownfield

Non-destructive. Swarm's skills have unique names (`pass-*`, `persona-*`, `write-*`, `implement-and-verify`)
that can't collide with yours. The only merge point is the root `AGENTS.md`/`CLAUDE.md`. Existing code is
`observed` until an audit + a spec govern it — adoption does not retrofit specs. See
[`model/workspace.md`](model/workspace.md) for the source-code surface policies.

## Upgrading

Re-copy the kit from a newer `starter-kit/`. Skills overwrite the `pass-*`/`persona-*`/`write-*`/
`implement-and-verify` entries; **your own (differently-named) skills, your `specs/`/`memory/`, and your
filled `AGENTS.md` are untouched**. There's no version file to bump and no mount to replace — the framework
version is a producer release tag, and you just re-copy to move forward.
