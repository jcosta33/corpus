# `memory/INDEX.md` — the recall map

`memory/INDEX.md` is Swarm's Tier-1 recall map: a compact, always-cheap index of links over the durable knowledge a project has earned, where every entry names the trigger that says *when* a future task should load it. It is the entry point of the memory subsystem — the first thing an agent reads to decide what durable knowledge is relevant to the task in front of it — and it is the producing target the `promote` pass writes a `Load when` row into whenever a discovery is made durable.

## Purpose and epistemic stance

The index asserts one kind of knowledge and one only: **a map of where durable knowledge lives and when it becomes relevant.** It is the "map," never the "territory." Its job is recall routing, not the knowledge itself.

What it MUST do:

- Link into the Tier-2 evidence store — `finding.md`, `adr.md`, `memory/patterns/*.md` — and let an agent decide, cheaply, which of those to open.
- Carry, on **every** entry, a `Load when` condition: the trigger that tells a future agent the entry is relevant to its current task. This is the load-when discipline, and it is normative.
- Stay small enough to remain in the always-loaded recall budget [[LOSTMID]](../research/sources.md#LOSTMID). The index is read first on tasks that may depend on prior work; the verbose bodies are read lazily, only when a `Load when` matches — because context is a finite resource and a task should load only the durable knowledge it names [[CTXENG]](../research/sources.md#CTXENG).

What it MUST NOT do:

- It MUST NOT duplicate or restate the body of any Tier-2 artifact. A summary line here is a pointer, not a copy; if a reader needs the claim, they follow the link. A conformant recall tool MAY treat a divergence between an index summary line and the linked artifact as advisory drift, never as a second source of truth.
- It MUST NOT carry its own obligation blocks. The index is a working artifact (recall routing), not intent: it holds no `REQ`/`CONSTRAINT`/`INVARIANT`/`INTERFACE` and weakens no obligation. A discovery that *is* intended behavior promotes into a `spec.swarm.md`, not into this map; the index only gains a row when that discovery also lands as an indexable durable fact.
- It MUST NOT retain an entry that cannot name when it matters. An entry without a usable `Load when` is dead weight against the recall budget and MUST be removed. "Says when to load each entry" is the whole contract; an entry that fails it is not an index row.

Two adjacent files complete Tier-1 but are governed by their own contracts, not this one. `memory/glossary.md` holds term definitions (one word, one meaning); `memory/INDEX.md` holds the recall map only — do not mix definitions into the index. Retired or contradicted knowledge is not silently deleted: it is recorded in the index's stale/superseded table with its replacement, so the recall chain stays auditable.

## Filename and placement

`memory/INDEX.md` is a **working artifact**: a human/agent recall map, not a compiler input. By the `.swarm.` infix rule that partitions every pipeline file, it is therefore a plain `.md` file and MUST NOT carry the `.swarm.` infix:

| Class | Infix | This artifact |
| --- | --- | --- |
| Human-authored compiler-visible spec | `*.swarm.md` | no — the index is not a SOL source |
| Emitted compiler artifact | `*.swarm.*` (e.g. `*.swarm.ir.json`) | no — the index is not emitted by the compiler |
| Working artifact | plain `.md`, no infix | **yes** — `memory/INDEX.md` |

A conformant tool keys off the infix as the sole discriminator for "do I parse this as SOL," so the plain name is load-bearing: it marks the index as a contracted Markdown artifact, never a SOL source.

In an adopted `.swarm/` workspace the index lives under the durable recall directory, beside its Tier-1 and Tier-2 neighbors:

```text
.swarm/
  memory/                # DURABLE recall (committed; populated by the promote pass)
    INDEX.md             # <- this artifact: Tier-1 recall map
    glossary.md          # Tier-1 one-word-one-meaning term store
    patterns/            # Tier-2 recurring multi-finding knowledge
    stale/               # superseded/contradicted memory, linked to replacements
  sources/               # DESIRED truth + durable source artifacts the index points at
    findings/  adrs/     # finding.md and adr.md — Tier-2 evidence store
  generated/             # EPHEMERAL execution packets (task frames, traces, reviews)
```

Placement follows one rule: anything that defines, tracks, or reconciles durable project knowledge lives in `.swarm/`. The index is durable recall, so it is committed and lives in `.swarm/memory/`. It points *into* `.swarm/sources/` (the findings and ADRs it indexes) and is never confused with `.swarm/generated/` (recreatable execution packets, often gitignored). It is the `promote` pass that adds, advances, retracts, and supersedes the index's rows.

## Required sections and fields, in order

### Frontmatter contract

```yaml
type: memory-index   # fixed
id: memory-index     # fixed
status: active
updated: <timestamp> # last time the map changed
```

`type` and `id` are both the literal `memory-index`; the index is a singleton per workspace. `status` is `active`; `updated` records when the map last changed so a reader can judge its freshness against the work.

### Sections, in order

| # | Section | What it means |
| --- | --- | --- |
| 1 | `## Purpose` | One or two lines: this is the compact map of durable project knowledge; read it before tasks that may depend on prior discoveries, and follow a link only when its `Load when` matches. |
| 2 | `## Always-relevant project facts` | The few durable facts loaded on **every** task (their `Load when` is "always"). Keep this list short — it is the only part of memory not gated behind a trigger, so each line spends always-loaded budget. |
| 3 | `## Topic files` | Table `Topic → File → Load when`. One row per `memory/patterns/*.md` topic artifact. A pattern distils two or more corroborating findings; link the file, name the trigger, do not restate the pattern. |
| 4 | `## Durable findings` | Table `Finding → Status → Load when`. One row per `finding.md` in the evidence store. `Status` mirrors the finding's own status (`candidate \| accepted \| promoted \| rejected \| stale \| superseded`); `Load when` mirrors the finding's `applies_when` scope envelope. Link the file; do not restate its claim. |
| 5 | `## Decisions` | Table `ADR → Status → Load when`. One row per `adr.md` whose decision a future task should recall before touching the affected area. |
| 6 | `## Stale or superseded memory` | Table `Item → Replacement → Action`. The retraction ledger: a promoted entry later shown stale, contradicted, or withdrawn is recorded here with its replacement and the action taken (re-verify, supersede, roll back) — not deleted. This keeps the recall chain auditable. |

Every row in sections 3–5 MUST carry a `Load when`. The recurring discipline across the whole file: link, name the trigger, never copy the body.

## Copyable template

The copyable skeleton is the kernel template:

```text
starter-kit/.agents/templates/memory/INDEX.md
```

That template is the skeleton you copy into a new workspace (it installs to `.swarm/memory/INDEX.md`); **this page is its contract** — what each section and field means and the rules the skeleton must be filled out to satisfy. Copy the template, then populate it under the load-when discipline above: one row per durable artifact, each with the trigger that surfaces it, and remove any row that cannot name when it matters.

## Related

- [`finding.md`](finding.md) — a single durable, provenance-anchored project fact; the Tier-2 artifact a `## Durable findings` row links to.
- [`adr.md`](adr.md) — an immutable architecture/product decision; the Tier-2 artifact a `## Decisions` row links to.
- [The `promote` pass](../passes/promote.md) — the pass that earns a discovery its durability and writes (advances, retracts, supersedes) the index's rows; the producer of this artifact.
- [The `review` pass](../passes/review.md) — surfaces the discoveries and verdicts that the `promote` pass turns into indexed memory.
