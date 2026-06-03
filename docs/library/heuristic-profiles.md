# Heuristic profiles

> Swarm's reference for **heuristic profiles**: the optional cognitive stances that sharpen a pass without changing what the pass means — what a profile is, the seven-section profile contract (including the `## Refuses` red-flag table), the six stdlib profiles and the full thirteen-stance set, where profiles ship, and the single-axis profile-by-pass routing model.

A **heuristic profile** is an optional cognitive stance applied to a pass. It changes *what an agent looks for and refuses* while performing the pass; it never changes *how* the pass runs — that is the job of the pass guide — and it never defines load-bearing meaning. A profile is a parameter, not a person: it is not a character, not an actor, and not a procedure. Like every Swarm surface, a profile is **markdown only with no runtime**; it is a contract a human or an agent reads and adopts, never code that executes.

## What a profile is (and is not)

The Swarm compiler runs **nine passes** in a fixed order — `author -> lint -> improve -> lower -> decompose -> implement -> verify -> review -> promote`. Each pass is a transformation with a contract of its own. A profile sits *over* a pass and tilts the agent's attention: it states the failure class the stance exists to catch, the questions it forces, the evidence it demands, and the patterns it rejects on sight. The transformation itself is unchanged.

Three properties are normative:

- **A profile defines no semantics.** A profile MUST NOT define a modality, an authority-order rule, a verdict value, a proof type, a lint code, a merge-gate predicate, or any other load-bearing meaning. Those live exclusively in the language reference and the typed intermediate representation. Where a profile *names* a verdict (`PASS`, `UNVERIFIED`, …), a proof type, the proof-strength order, or the merge gate, it is **citing** that vocabulary, never minting it. A profile is a soft-control, skill-shaped file: it informs judgment, it does not bind it.
- **A profile is optional.** Every pass is well-defined with no profile loaded. A profile *sharpens* a pass; it is never required for the pass to be valid. A task names a pass and MAY additionally name the profile that sharpens it.
- **A profile's carrier is an implementation detail.** A profile MAY ship as a standalone file — one profile per file — or be inlined into a pass guide. Conformance checks the *contract* (the seven sections below), not the carrier. The rationale is that the mindset is the durable object; the file that carries it is incidental. A standalone file is one carrier option, the one the stdlib uses.

## The profile contract

Every heuristic profile declares exactly these seven sections, in this order:

```markdown
# Heuristic profile: <name>

## Prevents
## Default questions
## Required evidence
## Refuses
## Self-review delta
## Applies when
## Does not apply when
```

Section semantics:

| Section | Content |
|---|---|
| `## Prevents` | the **one** failure class this stance exists to catch (a single clause). |
| `## Default questions` | the questions the stance forces the agent to ask while performing the pass. |
| `## Required evidence` | the evidence the stance demands before it accepts a claim. |
| `## Refuses` | the **red-flag table** — each row a pattern the stance rejects on sight, paired with the action it takes. |
| `## Self-review delta` | what the agent additionally checks in its self-review when this profile is active. |
| `## Applies when` | the pass / `task_kind` conditions under which the profile is appropriate. |
| `## Does not apply when` | the conditions under which the profile MUST NOT be loaded — the guard against misapplication. |

### The `## Refuses` red-flag table

The `## Refuses` section is the heart of a profile: an enumerated **refusal set** rather than a single sweeping rule. Each row pairs a red flag — a pattern the stance recognizes as a likely defect — with the action the stance takes when it sees that pattern. Enumerating the refusals (instead of stating one broad "iron law") is what lets the stance reject the *specific* failure modes its pass invites, and lets a reader audit exactly what it will and will not let through. The dispositions a row names (`reject`, `UNVERIFIED`, …) are applications of vocabulary owned elsewhere; the table *applies* that vocabulary, it does not define it.

For example, the Skeptic stance — the canonical reference profile — refuses summary-only proof (demand the artifact), "tests passed" with no command, exit code, or output (reject as `UNVERIFIED`) [[REFLEXION]](../research/sources.md#REFLEXION), a trace whose evidence does not match the obligation it claims (reject as `UNVERIFIED`), and the implementer rendering the verdict on their own change (reject; require an independent reviewer). Each row is a concrete trap the `review`/`verify` passes are prone to, named so the stance catches it on sight.

## The six stdlib profiles

The kernel models **thirteen** heuristic stances (the full set is mapped below). The stdlib ships a **six-file subset** as installed, ready-to-load profiles — the stances that cover the most common entry points across the pipeline:

| Stdlib profile | Stance | Pass(es) it parameterizes |
|---|---|---|
| `skeptic.md` | refute-by-default — assume a completion claim is unproven until its evidence forces the opposite conclusion. | `review` / `verify` |
| `builder.md` | constructive build — turn obligations into working surfaces under the assigned scope. | `implement` (`feature`, `rewrite`) |
| `architect.md` | intent-not-implementation — keep specs verifiable and free of smuggled implementation; survey before reinventing. | `author` (spec-writing) |
| `researcher.md` | inquiry against external evidence — investigate a question in depth against primary sources. | `author` (research-writing) |
| `reviewer.md` | the Skeptic stance narrowed to the `review` pass (a convenience alias, **not** a fourteenth stance). | `review` |
| `janitor.md` | tidy-as-you-go, minimal-footprint, behavior-preserving change. | `implement` (`refactor`) |

`reviewer.md` is a named alias: it carries the Skeptic stance focused on the single pass it most often parameterizes, so that a task naming `profile: reviewer` resolves to a present, conformant carrier for the `review` pass without minting a new mindset. The substance lives in `skeptic.md`; load that directly whenever the pass is `verify` (or the `fix` task kind for root-causing), which the alias does not cover.

## The full thirteen-stance set, mapped to passes

The thirteen stances map onto the nine passes as follows. This is the routing the framework uses; the stances that do not ship as standalone stdlib files are still part of the model and MAY be carried inline in a pass guide or installed by a project.

| Profile | Pass(es) it parameterizes |
|---|---|
| Skeptic | `review` / `verify` |
| Architect | `author` (spec-writing) |
| Auditor | `author` (audit-writing) |
| Surveyor | `author` (research — breadth / inventory survey) |
| Researcher | `author` (research — depth / external evidence) |
| Bug Hunter | `author` (bug-report-writing) |
| Janitor | `implement` (`refactor`) |
| Migrator | `implement` (`migration` / `upgrade`) |
| Performance Surgeon | `implement` (`performance`) |
| Builder | `implement` (`feature` / `rewrite`) |
| Test Author | `implement` (`testing`) |
| Documentarian | `implement` (`documentation`) |
| Lead Engineer | `decompose` / merge-gate (`review` over the obligation set) |

All thirteen are uniformly heuristic profiles: there is no two-tier "persona vs profile" split. Surveyor and Researcher share one evidentiary stance and differ only on breadth versus depth. Builder and Janitor are constructive and behavior-preserving counterparts on the same `implement` pass.

## Profile × pass: the routing model

Routing in Swarm is **profile × pass**. A task names exactly one pass — the transformation it frames over its assigned obligations — and MAY name the profile that sharpens it. The `task_kind` frontmatter value is what selects the profile inside the two passes that vary by kind: the nine implementation kinds all route to `implement` and differ only in which profile and pass guide apply (`feature`/`rewrite` → Builder, `fix` → Skeptic, `refactor` → Janitor, `migration`/`upgrade` → Migrator, `performance` → Performance Surgeon, `testing` → Test Author, `documentation` → Documentarian); the authoring kinds all route to `author` and select Architect, Researcher/Surveyor, Auditor, or Bug Hunter. The `review` kind selects the `review` pass under the Skeptic stance; `orchestration` and `integration` route to `decompose` plus a merge-gate `review` under the Lead Engineer stance.

Routing is this **single axis** — profile × pass — rather than a pair of lookup tables keyed on task type and document type. A conformant repo MUST express routing as profile × pass and MUST NOT introduce a persona-per-task-type or persona-per-document-type matrix. The rationale is concrete: a per-task-type or per-document-type matrix duplicates the same mindset across many cells; routing every stance onto the pass axis removes that duplication and makes the question "which stance applies here?" answerable from the pass and the `task_kind` alone.

## Where profiles ship

The six stdlib profiles ship in the kernel payload at **`kernel/.agents/profiles/`** — one file per profile (`skeptic.md`, `builder.md`, `architect.md`, `researcher.md`, `reviewer.md`, `janitor.md`). In an adopted project the same files are installed at `.swarm/kernel/profiles/`. A profile a project authors itself lives alongside them. Because a profile's carrier is incidental, a project that prefers to inline a stance into its pass guide is equally conformant, so long as the seven-section contract is satisfied.

## Authoring a profile

When you write a new profile, the first decision is the one that keeps the file conformant: a profile is a **cognitive stance that parameterizes a pass**, not an org role or a named character. Swarm deliberately rejects the "named persona" model some frameworks use — *Mary the Analyst*, *Devon the Dev*, and the like. A profile is named after the stance the pass needs (`skeptic`, `builder`, `architect`), never after a person; it implies a frame of mind, not a personality; and it earns its keep by enumerating constraints, not by encouraging roleplay. The test is concrete: if the name evokes a character to inhabit, it is a costume; if it names *what the agent looks for and refuses* while running a pass, it is a profile. Switching profiles should feel like changing tools, not changing actors — which is also why the stance set stays small and memorable rather than sprawling into a cast. For why this stance-not-character framing makes the discipline durable under attention pressure, see [the evidence](../research/body-anatomy.md).

In practice, two parts of the seven-section contract carry the weight of the stance and are worth drafting first:

- **The Stance.** State, in one line, the failure class this profile exists to catch and the frame of mind it imposes — the substance that fills `## Prevents` and tilts the rest of the sections. The Skeptic's stance is refute-by-default; the Builder's is constructive build under the assigned scope; the Janitor's is behavior-preserving minimal-footprint change. Everything else in the profile follows from that one sentence.
- **The `## Refuses` red-flag table.** This is where the stance becomes auditable. Shape it as a two-column table — each row a red flag the stance recognizes on sight, paired with the disposition it takes (`reject`, mark `UNVERIFIED`, require an independent reviewer, …). Enumerate the *specific* traps this profile's pass invites rather than stating one sweeping rule; the row's disposition cites vocabulary owned by the language reference and the pass guides, it never mints new meaning. A reader should be able to scan the table and know exactly what the stance will and will not let through.

Keep the profile short [[SKILLBP]](../research/sources.md#SKILLBP). The other five sections (`## Default questions`, `## Required evidence`, `## Self-review delta`, `## Applies when`, `## Does not apply when`) sharpen the stance and guard against misapplication, but they are downstream of the one-line stance and the refusal set. If those two are crisp, the profile does its job.

## Related

- [Pass guides](pass-guides.md) — the pass-guide model: *how* a pass runs, the layer a profile sits over.
- [Overlays](overlays.md) — project rule bundles, the other parameterizing layer alongside profiles.
- [The `review` pass](../passes/review.md) — the merge gate and the seven-value verdict vocabulary the Skeptic/Reviewer stance applies.
- [The `verify` pass](../passes/verify.md) — the proof taxonomy and proof-strength order a profile's `Required evidence` cites, never defines.
- [The `author` pass](../passes/author.md) — the authoring pass the Architect, Researcher, Surveyor, Auditor, and Bug Hunter stances sharpen.
- [The `implement` pass](../passes/implement.md) — the build pass the Builder, Janitor, Migrator, Performance Surgeon, Test Author, and Documentarian stances sharpen.
- [The `decompose` pass](../passes/decompose.md) — the pass the Lead Engineer stance parameterizes en route to the merge gate.
