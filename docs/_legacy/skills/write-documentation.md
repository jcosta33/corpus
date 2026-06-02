# Skill (documentation): `write-documentation`

> **For agents:** instructions → [`/scaffold/.agents/skills/write-documentation/SKILL.md`](../../scaffold/.agents/skills/write-documentation/SKILL.md)

---

## TL;DR

User-facing docs that hedge, ship examples that were never run, or quietly contradict the code are *worse* than no docs — they mislead with authority. `write-documentation` is the discipline that keeps the doc honest for the one reader who matters: a human who has not read the code, has a question, and needs it answered.

## The failure mode it prevents

Documentation rots in three predictable ways, and each one is actively harmful rather than merely useless:

- An example that "should work" but was never executed — copy-paste it and the reader's trust dies on the first error.
- A behaviour claim that drifted away from the code months ago and now lies about what the system does.
- A long throat-clearing preamble that buries the one action the reader came for under "before we begin, let's discuss…".

The skill treats all three as defects, not stylistic preferences.

## Core rules (summarised)

- **Lead with the action.** The first 100 words contain the thing the reader's question is asking about. Background follows only if needed.
- **One Diátaxis frame per doc.** Tutorial, how-to, reference, or explanation — pick exactly one. Mixing modes confuses readers in all four. If you find yourself switching mid-doc, split it.
- **Every example runs as written.** Run it, capture the output, confirm it is self-contained. An example you didn't run is a hypothesis, not an example.
- **Every behaviour claim cites file:line.** If you can't find the line, the claim is suspect — verify before publishing.
- **No hedging.** "Should / might / could" are words the reader cannot act on. Either the system does X or it doesn't; if it's conditional, state the condition.
- **Update the world when it changes.** Stale docs beat no docs only in the imagination. Touch code that an existing doc describes, and you reconcile that doc in the same change — grep for siblings that now contradict you.

The full rule text, with examples, lives in the SKILL.md body. The point of the skill is that it converts "write good docs" into a hard gate the agent verifies before declaring done.

## Audience boundary

This skill is for material a *human* reads to learn or look up. It explicitly does **not** cover agent-facing material — skill bodies, task templates, internal flow docs. Those serve a different audience and follow different conventions. Don't reach for `write-documentation` when the artefact's reader is another agent.

## Task type and suggested persona

`write-documentation` carries the discipline for the [`documentation`](../tasks/documentation.md) task type. The matching mindset is the **Documentarian** — one of the six mindsets that do *not* ship as a standalone persona skill; the temperament rides along with `write-documentation` itself. Review of a finished doc is the Skeptic's job: did every example actually run, does every claim survive a check against file:line.

This is a *suggested* default, not a gate. If the doc work in front of you fits a different shape, load the skill whose description matches and record the divergence in your task file's `## Decisions`.

## Project commands it reads

The skill resolves project commands through the consuming repo's `AGENTS.md > Commands` — `Validation` and `Format`, run on the doc before commit. An optional doc-lint command (`markdownlint`, `vale`) is **not** in the standard contract; the skill asks the user whether the project uses one rather than guessing. If `AGENTS.md` is missing an entry, it asks before proceeding.

## What it ships

`references/task-template.md` — a fillable documentation-task template: doc target (Diátaxis frame, audience, the reader's question), source material, an examples-to-verify table, a progress checklist, and a self-review hard gate covering reader-first ordering, examples-actually-ran, currency, and doc-type integrity. Copy it into your project's task-file location, substitute the `{{...}}` placeholders, and fill it in as you work.

## Related

- [Task: documentation](../tasks/documentation.md)
- [Building skills: self-containment](building/self-containment.md) — why this skill carries no cross-skill links and resolves commands through `AGENTS.md`
- The [Diátaxis](https://diataxis.fr) framework — the doc-type vocabulary the skill enforces
