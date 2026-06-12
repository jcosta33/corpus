# `.agents/skills/` — the dev subset (manifest)

`.agents/skills/` is **not** the shipped catalogue. It is the small set of guides for working
**on this repo** — implementing changes to the docs and the checks contract. The shipped
surfaces are the starter kit's guides
([swarm-starter-kit](https://github.com/jcosta33/swarm-starter-kit) — the core loop plus the
workspace authoring guides), the optional catalog
([swarm-skills](https://github.com/jcosta33/swarm-skills) — conditioning stances and
code-authoring depth), and the reference pages under `docs/reference/`. The family workspace
that plans and reviews changes to this repo is the sibling `swarm-hq` repo.

## Single-sourcing

A rule lands in `docs/` first (with an ADR under `docs/adrs/`), then the kit repo, the catalog,
and every derived surface. Never change a rule only here; this subset must not become a
competing authority.

## Census — included, and why

| Guide                   | Counterpart                                                                                              | Why it is here                                                                                                      |
| ----------------------- | --------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| `implement-task`        | mirror of the kit's `.agents/skills/implement-task/` (swarm-starter-kit repo)                              | Tasks cut in the swarm-hq workspace are implemented in this repo; the implementing session loads the core guide here. |
| `empirical-proof`       | the catalog's `empirical-proof` (repo-adapted copy)                                                        | The evidence rules in standalone form: a completion claim binds to pasted output; without it the result is Unverified, never Pass. |
| `persona-documentarian` | the catalog's `persona-documentarian`                                                                      | The stance for the human-facing pages this repo ships: one frame throughout, every example run, every claim cited.    |

## Census — omitted, and why

| Guide                                                                                  | Why not here                                                                                       |
| --------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| `write-spec`, `review-output`, and the workspace authoring guides (`write-audit`, `write-research`, `write-rfc`, …) | Authoring, review, and Close-step work runs from the swarm-hq workspace; its `.agents/skills/` carries them. |
| The other personas and the per-change-shape implementation guides                       | They live in the swarm-skills catalog; install into whichever workspace needs them.                  |

Templates are not skills: the frozen formats ship in the kit repo's `templates/` and
`advanced/` — link to them, never restate them.

Keep `implement-task` byte-identical to the kit repo's copy — the kit is where it is edited;
a drift here is a defect.
