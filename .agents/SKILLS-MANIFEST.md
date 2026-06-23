# `.agents/skills/` — the dev subset (manifest)

`.agents/skills/` is **not** the shipped catalogue. It is the small set of guides for working
**on this repo** — implementing changes to the docs and the checks contract. The shipped
surfaces are the starter kit's guides
([corpus-starter-kit](https://github.com/jcosta33/corpus-starter-kit) — the core loop plus the
workspace authoring guides), the optional catalog
([corpus-skills](https://github.com/jcosta33/corpus-skills) — conditioning stances and
code-authoring depth), and the reference pages under `docs/reference/`. The family workspace
that plans and reviews changes to this repo is the sibling `corpus-hq` repo.

## Single-sourcing

A rule lands in `docs/` first (with an ADR under `docs/adrs/`), then the kit repo, the catalog,
and every derived surface. Never change a rule only here; this subset must not become a
competing authority.

## Census — included, and why

| Guide             | Counterpart                                                                    | Why it is here                                                                                                                     |
| ----------------- | ------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------- |
| `implement-task`  | mirror of the kit's `.agents/skills/implement-task/` (corpus-starter-kit repo) | Tasks cut in the corpus-hq workspace are implemented in this repo; the implementing session loads the core guide here.             |
| `empirical-proof` | the catalog's `empirical-proof` (repo-adapted copy)                            | The evidence rules in standalone form: a completion claim binds to pasted output; without it the result is Unverified, never Pass. |

## Census — omitted, and why

| Guide                                                                                                                                                              | Why not here                                                                                                                                                                                  |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `write-spec`, `review-output`, and the workspace authoring guides (`write-audit`, `write-research`, `write-rfc`, …)                                                | Authoring, review, and Close-step work runs from the corpus-hq workspace; its `.agents/skills/` carries them.                                                                                 |
| The conditioning stances (now only the cross-cutting `persona-skeptic` / `persona-challenger` / `persona-surveyor`) and the per-change-shape implementation guides | They live in the corpus-skills catalog; install into whichever workspace needs them.                                                                                                          |
| The documentarian discipline (was a local `persona-documentarian` copy)                                                                                            | Folded into the catalog's `write-documentation`, its single source ([ADR-0093](../docs/adrs/0093-collapse-1to1-personas.md)); install that guide when writing this repo's human-facing pages. |

Templates are not skills: the frozen formats ship in the kit repo's `templates/` and
`advanced/` — link to them, never restate them.

Keep `implement-task` byte-identical to the kit repo's copy — the kit is where it is edited;
a drift here is a defect.
