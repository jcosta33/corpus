---
type: adr
id: 0048-installed-payload-is-the-runtime-surface
status: superseded
created: 2026-06-06
updated: 2026-06-06
supersedes:
superseded_by: 0049-minimal-install-no-mount-no-imposed-workspace
---

> **Superseded by [ADR-0049](./0049-minimal-install-no-mount-no-imposed-workspace.md).** The "what to ship"
> conclusion survives — skills + the compact `reference/` cards + templates, not the manuals or corpus (see
> this ADR's Update). What 0049 overturns is the *destination*: that payload no longer mounts at
> `.swarm/kernel/`; it installs in place beside the project's own skills, with no symlink bridge.

# ADR-0048: The installed payload is the runtime surface, not the whole kernel

## Context

ADR-0040/0044 defined the installable payload as `starter-kit/.agents/` and shipped it **wholesale** into an
adopter's `.swarm/kernel/` — `skills/`, `templates/`, `language/` (the full SOL/APS/errors/versioning
manuals), `passes/` (the nine pass reference docs with rationale), `conformance/` (the golden corpus),
and `memory/`. The justification was offline self-containment.

Adopting `swarm-cli` made the cost visible: ~1.2 MB of framework documentation copied into the repo, of
which an agent **loads almost none** at runtime. Per the load-what-the-task-names doctrine, an agent
loads the *skill* the task names; it never opens the full `passes/`/`language/` manuals or the
conformance corpus. With skills now self-contained ([0047](./0047-skills-are-self-contained.md)), the
only thing that made the kernel ship `passes/` + `language/` — keeping skill citations from dangling —
is gone. The corpus (`conformance/`) is test data for a *checker*, never used by an adopting project.

## Decision

1. **The installed payload is the runtime surface only:** `skills/` (self-contained for *procedure*) +
   `reference/` (the compact operative cards — see the Update below) + `templates/` + the `memory/` seed +
   the `AGENTS.md` bootloader + `config.yaml` + `overlays/` + `.swarm-version`.
2. **`passes/`, `language/`, and `conformance/` are NOT installed.** They are the framework's **human
   reference and test data**, and they live canonically in the `swarm` repo (`docs/passes/`,
   `docs/language/`, and the conformance corpus). An adopter that wants the *rationale* reads the `swarm` repo.
3. The bootloader and skills **name** the deep manuals (provenance) but link nothing that isn't
   shipped, so the slim payload has no dangling refs.

This **refines ADR-0044**: `docs/` remains canonical, but the kernel no longer carries derived
`passes/`/`language/` *twins for shipping* — the self-contained skills are the shipped derivative, and
the deep reference stays upstream. (The twin-maintenance burden 0044 introduced shrinks accordingly.)

## Alternatives considered

| Alternative | Why rejected |
| --- | --- |
| Ship the whole kernel (status quo) | ~1.2 MB of reference an agent never loads, duplicated into every adopter; the user-visible bloat that prompted this. |
| Ship a compact normative *card* instead of the manuals | Originally rejected (a card is one more hop, and [0047](./0047-skills-are-self-contained.md) says the hop is unreliable). **The Update below overturns this** — see there. |
| Fetch the reference from the network on demand | Breaks offline use and pins a repo location; the reference is for *humans*, who can open the `swarm` repo. |

## Consequences

- **Positive:** the adopter's `.swarm/kernel/` drops to the runtime surface (skills + templates); no
  manuals, no corpus. Upgrades copy less; there is less to drift.
- **Negative:** an agent cannot read the full pass rationale offline. Acceptable: the skills carry the
  operational rules ([0047](./0047-skills-are-self-contained.md)); rationale is a human concern, upstream.
- **Neutral:** `starter-kit/.agents/{passes,language,conformance}` remain in the `swarm` repo (the reference +
  the corpus a future `swarm-core` checker tests against); they are simply outside the installed subset.

## Update (2026-06-06): the compact reference is shipped after all

A self-containment audit (three readers checking whether the slim payload can carry an agent to full
compliance) overturned alternative #2. Two gaps showed the original trim went too far:

1. **De-linking ≠ self-containing.** Dropping `passes/`/`language/` rewrote skill citations from links to
   bare *names*, but the named facts — the SOL block grammar, the 9 proof types + oracle-adequacy rule,
   the 7-value verdict + merge gate, the IR/edge schema, the per-`task_kind` suites — were never folded
   *into* a skill. They became orphans: the skill pointed at a manual that no longer ships.
2. **Two passes had no skill at all.** `improve` and `lower` shipped no guide, so their procedures (the ten
   improve operations; the surface→IR lowering contract) were unreachable from the payload.

The fix keeps 0047's principle intact and corrects the boundary: a skill carries its pass **procedure**
inline (0047), but the **shared closed-set facts** every pass leans on are factored into three compact
**operative** cards — `reference/sol.md`, `reference/proofs.md`, `reference/ir.md` — that ship with the
payload. These are not the manuals (no rationale, no worked examples — those stay upstream); they are the
*rules*, ~12 KB total. The 0047 "the hop is unreliable" worry applied to *rationale* citations an agent
skips; an operative card the running pass needs is loaded *because* it is operative, the same reason the
skill is. Added `pass-improve-spec` and `pass-lower-spec` so all nine passes have a guide.

Net payload is still far below the wholesale kernel (the manuals + corpus remain unshipped); the cards add
~12 KB, not the ~1.2 MB this ADR removed.

## Status

Accepted (v0.1), amended 2026-06-06 (see Update). `ADOPTING.md` copies the runtime subset
`{skills, reference, templates, memory}` + `.swarm-version`; `swarm-cli`'s `.swarm/kernel/` carries the
skills + the three reference cards (still far below the 1.2 MB wholesale kernel — manuals + corpus stay
upstream).

## Affected obligations / constraints

- Refines: [0044](./0044-kernel-is-derived-and-self-contained.md) (kernel no longer ships passes/language
  twins), [0040](./0040-kernel-payload-directory.md) (payload = a defined subset of `starter-kit/.agents/`).
- Depends on: [0047](./0047-skills-are-self-contained.md) (self-contained skills make the trim safe).
- Does NOT change: `docs/` as canonical, any closed set, or the obligation grammar.
