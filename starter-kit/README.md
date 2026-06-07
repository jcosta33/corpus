# Swarm — the starter kit (a spec/docs repo)

This is the **authoring kit**: what you copy into a **spec / documentation repo** to author and review
high-quality Swarm specs. It is inert markdown (**NO RUNTIME**). Hand this folder to your coding agent and
point it at [`../docs/ADOPTING.md`](../docs/ADOPTING.md); it integrates the files into your repo.

It is **one kit, one purpose.** A code repo is not set up from here — see *Code repos* below.

## What's in it (→ your repo)

```text
starter-kit/.agents/skills/      →  <skills dir>        # the 20 authoring skills (author + lint/improve/
                                                        #   lower/decompose/review/promote + authoring personas)
starter-kit/.agents/reference/   →  .agents/reference/  # the rule cards: sol.md, proofs.md, ir.md
starter-kit/.agents/templates/   →  .agents/templates/  # artifact skeletons (spec, prd, rfc, audit,
                                                        #   finding, adr, research, bug-report, review, …)
starter-kit/.agents/memory/      →  .agents/memory/     # the recall seed (INDEX.md, glossary.md)
starter-kit/specs/               →  specs/              # per-feature folders (example: 001-contact-form/)
starter-kit/decisions/           →  decisions/          # numbered ADRs (seed: 0001-adopt-swarm.md)
starter-kit/AGENTS.md            →  AGENTS.md           # repo-root bootloader (fill Commands + project facts)
```

Skills go in whatever dir your agent CLI scans (`.claude/skills/` for Claude Code, else `.agents/skills/`),
beside your own — the `pass-*`/`persona-*`/`write-*` names don't collide. `.agents/` holds **only** this
tooling. Your **specs live in per-feature folders** — `specs/<feature>/spec.swarm.md` with each feature's
supporting docs (audit / research / bug-report / …) co-located beside it; **ADRs** go in numbered
`decisions/`; **findings** in `.agents/memory/`. No `.swarm/` mount, no symlink bridge, no version
file. ([ADR-0052](../docs/adrs/0052-per-feature-spec-folders.md))

## Code repos (not set up from this kit)

A code repo that *implements* a spec stays **pristine** — a good SOL spec is self-legible, so no reference
cards and no specs belong there. Its only optional Swarm skill is **`implement-and-verify`**, which lives in
the framework reference at [`../docs/library/code-skills/implement-and-verify/`](../docs/library/code-skills/) —
a code repo may copy that one skill and append [`.gitignore.additions`](./.gitignore.additions) for scratch.
The **PR** (naming obligation ids, with CI + review) is its trace and verdict; durable outcomes flow back to
the spec repo as a linked PR.

## What this kit deliberately does NOT contain

- **The SOL/APS/steps manuals** — the skills carry their procedure inline and the `reference/` cards carry
  the shared rules, so an adopter needs neither. The full manuals live in the `swarm` repo's `docs/`.
- **The code-implementation skills** — the per-kind implement guides and the code personas
  (`persona-bug-hunter`, `persona-builder`, …) are framework reference in
  [`../docs/library/code-skills/`](../docs/library/code-skills/), not kit content (a docs repo never runs them).
- **The validity corpus** — the golden corpus is producer test data at the `swarm` repo's top-level
  `conformance/`.

## Adopting

**The full guide (with a copy-paste agent prompt, per role) is [`../docs/ADOPTING.md`](../docs/ADOPTING.md).**
Nothing is enforced at runtime (there is none); validity is graded per role — a spec repo's bar is this
kit + a populated `AGENTS.md`, a code repo's footprint is near-zero.
