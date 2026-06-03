# Overlays — project-local rule bundles

> Swarm's reference for **overlays**: the optional, project-scoped bundles of non-kernel rules a repository layers onto the kernel — architecture conventions, extra refusals, local command bindings — without forking it; how an overlay composes with pass guides and profiles; and the hard boundary that an overlay MAY add project rules but MUST NOT override an approved obligation or the kernel's language semantics.

An **overlay** is the project-scoped guidance layer of the Swarm kernel. Where a pass guide documents *how* to perform one of the nine passes, and a heuristic profile documents *what an agent looks for and refuses* while performing a pass, an overlay documents *what this one project additionally expects* on top of both. It is how a repository encodes its house rules — its architecture conventions, its testing policy, its domain refusals, its local command bindings — without editing or forking the kernel that ships those passes and profiles.

Like every Swarm artifact, an overlay is **markdown-only** and has no runtime: it is a guidance file a human or an agent reads while performing a pass, never shipped code. The kernel's overlay directory is `kernel/.agents/overlays/`; the standard library ships it empty, because the kernel is complete without any overlay at all.

## What an overlay is

An overlay is an **OPTIONAL, project-scoped bundle of non-kernel rules**. Three properties define it:

- **Optional.** A conformant repository MAY ship zero overlays. Overlays add project-specific expectations; they are never required for the kernel, a pass, or a profile to be well-defined. The standard library ships none.
- **Project-scoped.** An overlay carries guidance the kernel deliberately does not ship — convention specific to one repository. It is the canonical home for the kind of rule that is true here but would be wrong to bake into the shared kernel.
- **Non-kernel.** An overlay's rules are project convention. They never define or redefine anything the kernel owns (see [The boundary](#the-boundary)).

Typical overlay content:

| Overlay carries… | Example |
|---|---|
| **Architecture conventions** | "New HTTP handlers register through the `router/` table, never inline in `main`." |
| **Testing policy** | "Every `task_kind: fix` ships a regression test that fails before the fix." |
| **Extra refusals** | "Refuse to bind a new third-party dependency without an ADR." |
| **Local command bindings** | "In this repo, the integration suite is `make itest`; name it where a pass needs it." |
| **Domain / house rules** | "Money is always minor units (integer cents); reject float currency in any spec." |

Overlays are the canonical home for architecture and testing-policy rules. Such rules are not pass guides — they document no pass — and not profiles — they carry no cognitive stance. They encode project-local convention, and that is exactly what an overlay is for. Keeping them as overlays prevents one repository's house rules from contaminating the shared standard-library pass guides.

## The overlay contract

Every overlay is a `*.md` file (or a directory of them) under `kernel/.agents/overlays/<name>/`, declaring this frontmatter and these four sections:

```markdown
---
type: overlay
name: <name>
version: 0.1.0
---

# Overlay: <name>

## Purpose
<the one project concern this overlay addresses, single clause>

## Applies to
<the passes, task_kinds, paths, or layers this overlay's rules govern>

## Rules
<the project-specific guidance, as an enumerated list>

## Rationale
<why this project holds these rules; never a restatement of kernel semantics>
```

| Section | Content |
|---|---|
| `## Purpose` | The single project concern the overlay exists to serve. One overlay, one concern. |
| `## Applies to` | The scope — which passes, `task_kind`s, paths, or layers the overlay's rules act as guidance under. This scope is what lets the overlay compose narrowly rather than apply everywhere. |
| `## Rules` | The enumerated project-specific rules: architecture, testing, and domain conventions, and nothing the kernel owns. |
| `## Rationale` | Why the project holds these rules, stated inline — never a restatement of a kernel definition. |

## How an overlay composes

An overlay is the most downstream object in the kernel's one-way, acyclic dependency chain:

```text
language definitions → artifact contracts → pass contracts → pass guides → heuristic profiles → project overlays
```

It sits *downstream of every kernel object*: it consumes language, artifact, pass, pass-guide, and profile contracts, and is consumed by nothing. Concretely, that means:

- **An overlay composes with a pass guide additively.** The pass guide supplies the procedure for the pass; the overlay adds the project's extra expectations *for that pass*, scoped by its `## Applies to`. The pass guide still owns *how* the pass runs.
- **An overlay composes with a profile additively.** The profile supplies the cognitive stance; the overlay adds project-specific things to look for or refuse on top. The profile still owns the stance.
- **Overlays MAY depend on any upstream node** — they may cite, link, or quote a language definition, an artifact contract, a pass contract, a pass guide, or a profile.
- **Nothing depends on an overlay.** An overlay MUST NOT introduce a back-edge into the chain: it MUST NOT be required to interpret SOL, and MUST NOT be named as a dependency of a pass guide, a profile, or a pass contract. Naming an overlay as upstream of any of those is malformed.

### Lazy activation by name

An overlay is **lazily loaded by name** — exactly like a pass guide or a profile, and for the same reason. A `task.md` names the overlay (or overlays) whose rules apply to its pass; only the named overlays load. Description-matching is the degraded fallback when a task fails to name one. An overlay MUST NOT be always-loaded. This keeps the active context to the pass guide, the profile, and the named overlays the work in front of the agent actually requires — not the union of every project rule the repository has ever written [[CTXENG]](../research/sources.md#CTXENG).

## The boundary

An overlay's whole purpose is to *add* project rules. The boundary is that it may add but may never override. An overlay is **purely additive guidance**; it never weakens, waives, or reinterprets anything the kernel marks authoritative. Stated as hard rules, an overlay:

- **MUST NOT define or redefine SOL or APS semantics.** The language belongs to the kernel.
- **MUST NOT define or redefine a kernel object** — a block type (one of the 7 blocks), a modal (one of the 5 modals), a verdict value (one of the 7 verdicts), a proof type (one of the 9 proof types), or a lint code (`SOL-<LAYER>NNN`).
- **MUST NOT override an approved obligation.** An overlay adds project expectations; it never relaxes, waives, or reinterprets an obligation the spec already approved. Waiver authority stays with a human or the spec owner — never an overlay.
- **MUST NOT be always-loaded.** It loads lazily by name, as above.

The reason the boundary is restated this sharply is that the overlay is the layer most tempting to abuse as a back door for project-local semantics — the place a repository would be tempted to quietly redefine a modal or weaken a verdict under the cover of "house rules." It cannot. An overlay is **SOFT control**: its rules are guidance for a model, not enforcement, and they bind nothing the kernel marks authoritative. A conformant repository confirms that no overlay defines or overrides any of the kernel objects enumerated above — the same regression check that confirms no skill, profile, or `AGENTS.md` section has smuggled in modality, authority order, or verification semantics, extended to cover overlays.

The clean way to read the boundary: if a rule changes *what this project additionally expects*, it is an overlay rule; if it changes *what the words mean or what counts as done*, it belongs to the kernel and an amendment, not an overlay.

### Where does a rule belong — overlay, pass guide, or AGENTS.md bootloader?

Before a rule lands as an overlay rule, one gating question decides whether the overlay is even its right home: **is this rule vendorable across a different language, a different CI provider, and a different agent?** The answer routes the rule to one of three places.

- **Portable → a pass guide.** If the rule would still produce its intended behaviour for a team on another language, CI, and agent — with nothing else loaded — it is universal *how-to-work* guidance, not project convention. It belongs to a pass guide in the standard library, not an overlay. An overlay that carries portable guidance is misfiled; it should be lifted into the pass guide so every adopter inherits it.
- **Project-local → an overlay.** If the rule is true *here* but would be wrong (or merely irrelevant) to bake into the shared kernel — a stack-specific convention, a local command binding, a house refusal — it is exactly what an overlay is for. This is the rule that fails the vendorability test because it is coupled to *this* repository.
- **A persistent project fact → the AGENTS.md bootloader.** If the rule is not a multi-step discipline an agent loads for a pass but a standing fact the agent should treat as always-true context — what this repo's architecture *is*, which command *is* the integration suite [[AGENTSMD-HARM]](../research/sources.md#AGENTSMD-HARM), what the domain *means* — it is persistent context, and persistent context lives in [the AGENTS.md bootloader](../model/conformance.md), not in a lazily-loaded overlay [[CTXENG]](../research/sources.md#CTXENG). Encoding a standing fact as an overlay forces the task to name it before the agent can see it, which is the wrong lifecycle for something that is always true.

The split matters because each layer has a different lifecycle: a pass guide is portable and inherited by every adopter, an overlay is project-local and loaded only when a task names it, and the bootloader is project-local but always resident. Misfiling a rule — a portable one trapped in an overlay, a standing fact buried behind lazy activation — costs adopters either reuse or visibility. For the evidence behind this three-way test and the failure modes of getting it wrong, see [the scope evidence](../research/scope.md).

## Where overlays live

| Path | Holds |
|---|---|
| `kernel/.agents/overlays/` | The overlay directory. The standard library ships it empty (with a README); a project populates it. |
| `kernel/.agents/overlays/<name>/` | One overlay — a `*.md` file or a directory of them, per [the contract](#the-overlay-contract). |

## Related

- [`improve`](../passes/improve.md) — a pass whose guide an overlay composes with additively, adding project expectations without changing the procedure.
- [`verify`](../passes/verify.md) — the pass an overlay's testing-policy and local-command-binding rules most often scope to.
- [SOL](../language/SOL.md) — the obligation language whose semantics an overlay MUST NOT define or redefine.
- [APS](../language/APS.md) — the prose standard an overlay MUST NOT redefine.
- [errors](../language/errors.md) — the `SOL-<LAYER>NNN` lint catalog an overlay MUST NOT add to or override.
- [conformance](../model/conformance.md) — where the regression check that confirms no overlay redefines a kernel object lives, and which records that overlays are not required for conformance.
- [workspace](../model/workspace.md) — the `.swarm/` / `.agents/` layout that resolves the `kernel/.agents/overlays/` location into an adopted project.
