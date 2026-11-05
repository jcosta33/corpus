---
type: adr
id: adr-0191
status: accepted
created: 2026-11-05
---

# ADR-0191 - Author refinements and adoption residue

## Context

[ADR-0190](./0190-tracker-first-and-shorter-authors.md) applied the top five recommendations of
the [2026-11-05 ecosystem research](../research/corpus-ecosystem-2026-11-05.md). That research also
proposed smaller sharpenings (§3) and named adoption and upgrade material that carries no load for
the sole owner (§5). ADR-0190 records its source by a path outside this repository; the research now
lives in `docs/research/`.

The evidence for each sharpening is first-hand or practitioner evidence:

- A per-task review passed every task while a broad review found nine structural defects.
- Codebase researchers who know the intended change report what should be, not what is.
- Skills that anchor agents on their own templates override the task's instructions.
- A vendor bugfix format states current, expected, and unchanged behavior.

## Decision

1. **Spec, inline first.** The one-sentence inline path is the first step, ahead of reading and
   writing.
2. **Spec, task outranks shape.** The task's instructions and the project's spec form outrank the
   skill's shape.
3. **Spec, defect pairing.** A defect fix pairs the repaired behavior with `When: always`
   requirements for what must stay unchanged, each verified by a check that fails on the original
   state.
4. **Audit, change-blind questions.** Before a planned change, each mapping question omits the
   change.
5. **Campaign, whole-design review.** Parallel streams get a whole-design review before dispatch and
   a combined review after they merge.
6. **No adoption residue.** The READMEs carry one install line. The `sus-*` cutover instructions,
   the extra install variants, and the adoption pitch are removed.
7. **Research records live in `docs/research/`.** The study map, the shape proposal, the ecosystem
   research with its raw notes, and the progression test are indexed in
   [docs/research/README.md](../research/README.md). They are dated records, not current product
   documentation.

## Narrowed decisions

- [ADR-0189](./0189-four-artifact-authors.md): its consequence that adopters remove the `sus-*`
  skills before installing no longer has a README instruction.
- [ADR-0190](./0190-tracker-first-and-shorter-authors.md): its context cites the research outside
  this repository. The record is now
  [corpus-ecosystem-2026-11-05.md](../research/corpus-ecosystem-2026-11-05.md).

## Consequences

- The four authors grow from 315 to 318 lines. No rule was cut, so the progression test was not
  rerun.
- [`skills/sources.md`](../../skills/sources.md) grounds each sharpening.

## Status

Accepted (2026-11-05). Narrows ADR-0189 and ADR-0190.
