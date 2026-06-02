# 🚫 Non-Goals

> The companion to [`PRINCIPLES.md`](PRINCIPLES.md). What Swarm explicitly is not. Read this when you're tempted to expand the framework's scope; the answer to "should Swarm do X?" is often here.

---

## ❌ Swarm does not run inference

Swarm is a documentation framework. It does not invoke models, manage tokens, or arbitrate sampling parameters. The agent CLI does that — Claude Code, Codex, Cursor, Aider, Devin, opencode, and friends. Swarm conditions the input to those CLIs by way of a well-structured task file. When a feature requires running a model, it belongs in the CLI repo, not here.

---

## ❌ Swarm does not provide an agent runtime

There is no runtime in this repo. No process manager, no scheduler, no daemon. The framework's artefacts are Markdown files, plus a contract for how a runner (any runner) should resolve placeholders and bind verification commands. See [`reference/template-placeholders.md`](reference/template-placeholders.md) for the contract.

---

## ❌ Swarm does not enforce a specific test runner, package manager, or language

`pnpm`, `cargo`, `pip`, `bundle`, `go test`, `mvn` — none of these appear in any **`/scaffold`** template shipped by this framework repo. Concrete commands exist only inside a **consumer project's** bindings (typically `AGENTS.md`) or language-specific notes you add locally.

The framework names verification *gate slots* (`{{cmdValidate}}`, `{{cmdTest}}`, `{{cmdBenchmark}}`); the project binds slots to commands. See [Principle 2](PRINCIPLES.md#2--language--and-runtime-agnostic-at-the-framework-level).

---

## ❌ Swarm does not solve long-context coherence

Long-running sessions, sliding context windows, summarisation strategies, persistent memory across sessions — these are agent-runtime concerns. Swarm provides a *resumption record* (the task file's `## Decisions` / `## Findings` / `## Next steps` sections) so a fresh session can pick up where the last one ended, but it does not solve the underlying problem of model context.

See [`concepts/11-session-lifecycle.md`](concepts/11-session-lifecycle.md) for what Swarm *does* address: the resumable trail.

---

## ❌ Swarm does not include a TUI, CLI, or any executable artifact

The framework repo has no source code that runs. It is documentation, scaffold artefacts, and (eventually) a conformance checker. The Swarm CLI lives in a separate repository. If you need a tool to use Swarm, install the CLI; the framework can also be adopted by hand.

---

## ❌ Swarm does not provide a plugin or extension API

There is no extension API at the framework level. Extension is by composition: projects add their own personas (overlays), their own task types (with the bar set high), their own skills (in `.agents/skills/domain/`), and their own placeholders within reserved namespaces.

A future plugin layer is plausible, but it would be a CLI concern, not a framework concern.

---

## ❌ Swarm's skill layer does not ship stack-, vendor-, or engineering-domain skills

The shipped skills are **universal agent-workflow disciplines** — how an agent shapes its work for a kind of task (feature, fix, audit, spec, …), not what an engineer should know about a problem domain. So the framework ships no `react-19-best-practices`, no `postgres-index-patterns`, no `auth-patterns`, no vendor runbooks. A skill that speaks React is dead weight in a Python service, and a domain-knowledge skill either couples to one stack or balloons into an everything-skill — both documented failure modes.

Stack-specific and engineering-domain knowledge has homes: the consuming project's `AGENTS.md` (for its commands, architecture, and conventions), its own `.agents/skills/domain/` folder, or a stack-specific skill collection vendored only when that stack is in play. The gating question for any candidate skill is whether a team on a different language, framework, CI provider, and agent could vendor it by itself and still get the intended behaviour. See [`skills/building/scope.md`](skills/building/scope.md).

---

## ❌ Swarm's skill layer contains no automation

The skill layer is a container for skills plus their surrounding documentation — nothing executable. No validation scripts, no CI workflows, no eval harnesses, no README generators, no "core" / "loader" / "index" skill that other skills depend on. Automation in the layer drifts out of sync with the skills it checks, locks consumers into one runtime, and invites tooling-of-tooling. If validation tooling proves load-bearing it lives in the maintainer's own CI, outside the layer; reviews are reviewer-driven against the authoring rules. This is the same boundary as [Principle 1](PRINCIPLES.md#1--documentation-first-not-tooling-first): if it runs code, it is not framework. See [`skills/building/scope.md`](skills/building/scope.md).

---

## ❌ Swarm does not include marketing or branding

No logos, no marketing site, no glossy comparisons. The README is the front door; the docs are the substance. Where comparisons to other frameworks appear (e.g., [`concepts/12-prior-art.md`](concepts/12-prior-art.md)), they cite sources and acknowledge tradeoffs honestly.

---

## ❌ Swarm does not provide internationalisation

The framework ships in English. Translation is welcome (a future contribution) but not in scope for v1.

---

## ❌ Swarm does not invent personas per session

Personas are catalogued. The catalogue lives in [`personas/`](personas/). Sessions adopt personas; they do not create them. Project-specific personas can be added via an overlay (a project-level persona file), but they go in the project's `.agents/skills/personas/`, not in the framework.

See [Principle 10](PRINCIPLES.md#10--the-catalogue-grows-but-slowly-and-with-evidence).

---

## ❌ Swarm does not allow back-filling specs from finished code

The distillation chain is unidirectional. Narrating finished code as a spec is forbidden. The right artefact for documenting what was built is *documentation* (a how-to, a reference page, an explanation), not a *spec* (a forward-looking, prescriptive contract). See [ADR 0003](adrs/0003-distillation-is-unidirectional.md).

---

## ❌ Swarm does not commit task files

Task files are worktree-local. They live under `.agents/tasks/`, which the project's `.gitignore` lists. Durable findings migrate to audits/specs/research before the session closes.

This is a hard rule — see [ADR 0004](adrs/0004-task-files-are-gitignored.md).

---

## ❌ Swarm does not enforce TDD as an iron law

Test-first ordering is a defensible discipline, and projects are free to adopt it via a project-specific skill (Superpowers' approach). The framework's position is neutral: tests are required (they appear in verification gates and Self-review) but their *ordering relative to implementation* is a project decision, not a framework decision.

---

## ❌ Swarm does not promise infinite recursion in delegation

The Lead Engineer pattern (one task spawning sub-tasks in their own worktrees) is bounded. The default recursion limit is 2 (a Lead Engineer may spawn workers, and those workers are not themselves Lead Engineers). Higher limits are possible — Lead-Engineer-of-Lead-Engineers — but raise carefully. Coordination overhead grows superlinearly with depth.

See [`concepts/08-recursion-and-delegation.md`](concepts/08-recursion-and-delegation.md).

---

## ❌ Swarm does not write-side-parallelise

Parallel write-side work is a known failure mode. Cognition AI's *Don't Build Multi-Agents* (2025) and the follow-up *Multi-Agents: What's Actually Working* (2026) converge on the same answer: read-side parallelism is fine; write-side parallelism causes coordination failure.

Swarm permits parallel research, audit, and review subagents (read-side). For *implementation*, the Lead Engineer pattern serialises writes through a single-threaded merge protocol. There are no parallel writers in Swarm.

See [`concepts/10-subagent-strategy.md`](concepts/10-subagent-strategy.md).

---

## ❌ Swarm does not promise zero false positives in conformance

The conformance checker (when it ships) validates structure, not substance. A project can pass conformance and still have a poorly written audit, an over-broad spec, or a vague bug report. Conformance is necessary, not sufficient. Quality is reviewed by humans and by the Skeptic; conformance is automated structural sanity.

---

## ❌ Swarm is not a methodology for greenfield product design

Swarm is for *coding* agents in *existing* repos (and greenfield codebases that are about to become real). It does not specify how to do user research, how to write a PRD, or how to scope a quarter. The Surveyor persona handles UX/market research that *informs* a spec, but the framework does not impose a product process on top.

For product process, look elsewhere (BMAD-METHOD, for example, has a fully ceremonialised product flow).

---

## How to use this document

When proposing a new feature, capability, or scope expansion:

1. **Check this list first.** If your idea is here, it's a non-goal — make the case for moving it out of non-goals (an ADR), or build it in a separate repo.
2. **Check [`PRINCIPLES.md`](PRINCIPLES.md) next.** If the idea conflicts with a principle, the principle wins until you've successfully argued otherwise.
3. **Then propose.** A proposal that survives both gates can become an ADR.

Non-goals are not forever. They are *current* boundaries. Some will graduate (we expect AGENTS.md hierarchical override semantics, for instance, to graduate from "out of scope" to "in scope"). When a non-goal graduates, this file gets updated and an ADR is written.
