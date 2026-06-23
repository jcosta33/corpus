# Memory: the advanced model

*Advanced design note — internal rationale; not needed to use Corpus.*

The core memory story is one folder and one rule: keep findings in `findings/`, and before
closing a task, record anything durable as a finding
([09-saving-findings.md](../09-saving-findings.md), template:
[`finding.md`](https://github.com/jcosta33/swarm-starter-kit/blob/main/templates/finding.md)). For most teams that is the whole system.
This page is for teams that outgrow it. Everything here is convention — nothing in this
repository enforces it; the finding scaffold ships as swarm-cli's `swarm promote`, and the Close
gate (no item left `pending`) is a review-checklist item the human confirms by hand — a
board-mutating `swarm close` is a non-goal.

You have outgrown the core when grep stops being recall: dozens of findings nobody re-reads,
agents re-deriving facts a finding already states, the same term meaning two things in two specs,
the same lesson learned three times by three people. The fix is not more writing — it is writing
that says **when it should be read**. Externalizing state to files is what makes multi-session
agent work tractable at all [[CTXENG]](../research/sources.md#CTXENG)
[[SCRATCHPAD]](../research/sources.md#SCRATCHPAD); the advanced model adds the routing that keeps
those files findable and trustworthy.

## The shape

The advanced model grows inside the folder you already have:

```text
findings/
  INDEX.md          # the load-when index — read first, links out
  glossary.md       # one word, one meaning
  patterns/         # distilled from corroborating findings
  retry-jitter.md   # ordinary findings, one file each
ledger/             # optional append-only history (created lazily — see below)
  changes/  merges/  promotions/
```

## The load-when index

`INDEX.md` is a map, never the territory: one row per durable item, each row a link plus a
**Load when** condition — the trigger that tells a future task this entry matters now.

- **Every entry names when it matters.** An entry that cannot say when to load it is dead weight
  and gets removed. This discipline exists because context is finite and badly used: material
  buried in the middle of a long always-loaded context is reliably missed
  [[LOSTMID]](../research/sources.md#LOSTMID), so the index stays compact and the verbose bodies
  are read lazily, only when a Load when fires [[CTXENG]](../research/sources.md#CTXENG).
- **Link, never restate.** A row is a pointer; if the summary line and the linked finding ever
  disagree, the finding wins.
- **Retired knowledge is recorded, not deleted.** A stale or withdrawn entry moves to a
  stale/superseded table with its replacement, so the recall chain stays auditable.

## The glossary

`glossary.md` holds term definitions: one word, one meaning, project-wide. It exists because
terminology drift is a real failure mode — two specs using "session" for different things will
eventually produce a task that implements the wrong one. A term whose meaning was clarified
during a task is exactly the kind of discovery that promotes here. Definitions live only in the
glossary; the index never mixes them into its map.

## Patterns

A pattern is a recurring solution shape — knowledge bigger than one fact. The rule that keeps
`patterns/` honest: **a pattern is written only from corroborating findings — at least two — and
cites the findings it generalizes.** A single finding never promotes straight to a pattern; one
observation is an anecdote, and an anecdote dressed as a pattern misleads every future reader
with unearned generality.

## Promotion: how a discovery becomes durable

The Close step's "save a finding" rule is the smallest case of a more general act: **promotion**
— an explicit, recorded decision that moves a discovery from task scratch into a durable,
indexed home. Each discovery a task surfaces becomes a queue item and resolves to one status:

| Status | Meaning |
|---|---|
| `pending` | raised, not yet resolved |
| `promoted` | written to its durable target and indexed with a Load when |
| `deferred` | recorded for a future task, with a reason |
| `rejected` | judged non-durable, with a reason — "task-local detail" lands here |
| `blocked` | cannot be promoted yet (e.g. waits on a decision), with a reason |
| `validated` | corroborated but not yet written — the intermediate stop for high-consequence items |
| `rolled-back` | promoted earlier, withdrawn later via a retraction entry |

**The close gate: a task does not close while any item is `pending`.** This is a review
checklist item — the reviewer checks the task's Findings section resolved every discovery — that
the human confirms before closing by hand (`swarm promote` scaffolds any finding; there is no
board-mutating `swarm close`). Two corollaries:

- **No silent drops.** "Keep it in the task only" is a real resolution — `rejected`, with the
  reason written down — never a quiet omission.
- `deferred`, `rejected`, and `blocked` each carry a reason; `validated` does not satisfy the
  gate by itself (it is on the way to `promoted`, not a terminal state).

Where a promoted item lands depends on what it is: an intended behavior becomes a spec amendment
(new or changed AC); a decision with alternatives becomes an ADR in `decisions/`; a reusable fact
becomes a finding; a recurring shape, a pattern; a clarified term, a glossary entry. One boundary
holds everywhere: **a promotion never weakens an existing requirement** — a discovery that argues
a requirement is wrong routes to a spec amendment, reviewed as one, never to a finding that
quietly relaxes it.

## Provenance

A finding is falsifiable only if it carries enough origin to check. The
[`finding.md`](https://github.com/jcosta33/swarm-starter-kit/blob/main/templates/finding.md) template carries the core (`from`, `date`,
`related`, Evidence, Where it applies / does not apply); teams running the advanced model record
the fuller set on each promoted finding:

| Field | What it records |
|---|---|
| claim | the one durable fact, stated as a single proposition |
| evidence | the pasted output, PR, or review packet that grounds it |
| origin | the requirement ids (`SPEC-x#AC-NNN`) and the task/review it came from |
| confirmed by | the human reviewer or tool that accepted it |
| date | when it was promoted |
| content hash | a hash of the cited source at promotion time — the staleness signal |
| confidence | high / medium / low |
| applies when / does not apply when | the scope envelope; mirrors the index row's Load when |

A finding whose Evidence section is a bare claim is chat, not memory — a completion claim
without real output behind it is not evidence [[EVIBOUND]](../research/sources.md#EVIBOUND).

## Validation and rollback

**Authorization is not validation.** An owner approving a finding checks that someone wants it
remembered, not that it is true. The distinction matters because a memory store is attackable:
an agent's memory can be poisoned through ordinary-looking interactions, with no privileged
access [[MINJA]](../research/sources.md#MINJA) — and a poisoned finding misleads every task
that loads it. Two mechanisms close the gap:

- **The `validated` stop.** A high-consequence promotion goes `pending → validated → promoted`,
  where `validated` requires independent corroboration: a second finding, a re-run of the
  evidence, or a reviewer who is not the promoting agent. A finding originating from an
  externally-authored source never skips this stop.
- **Rollback.** A promoted finding later shown wrong is withdrawn as `rolled-back` — recorded as
  a **retraction entry in the index, never a silent delete** — and anything that relied on it is
  re-opened. Retraction differs from supersession: supersession replaces a fact with a better
  one; rollback withdraws a fact that should never have been promoted. The audit trail keeps
  both distinct.

## Staleness

A finding does not stay true by being written down. When the source it cites changes — the file
is rewritten, the API moves, the measurement is re-run with a different result — the finding is
**stale**: not deleted, not authority, routed to re-verification or supersession. The content
hash above is what makes staleness checkable; the comparator that recomputes it is a tool
concern (see [future-cli.md](future-cli.md)) — today a stale finding is caught by the reviewer
who follows the evidence link and finds it pointing at something that no longer exists.

## The ledger

Findings preserve *what we learned*; the **ledger** preserves *what happened* — a compact,
append-only history that lets a team throw verbose execution scratch away without losing the
audit trail. Created lazily on first write, it carries one entry per completed change
(`changes/` — requirements covered, evidence, results), per merge decision (`merges/` — what
gated, what was out of scope), and per resolved promotion queue (`promotions/` — where each
discovery landed).

Two properties make it a ledger rather than a log: entries are **immutable** — a correction is a
new entry referencing the one it amends, so the truth is the chain, not the latest row — and
every field is **compacted from artifacts that already exist** (task packets, review packets,
the promotion queue), so it introduces no new evidence. Once a task's load-bearing content is in
the ledger, the task and review scratch may be archived or dropped; the committed findings,
ledger, specs, and decisions are what a team never throws away. A team that wants a ledger writes
the entry by hand at Close — a board/ledger-mutating `swarm close` is a non-goal (it would
adjudicate the human-owned verdict); `swarm promote` scaffolds the finding, the human records the rest.

## Related

- [09-saving-findings.md](../09-saving-findings.md) — the core findings workflow this page extends.
- [`finding.md`](https://github.com/jcosta33/swarm-starter-kit/blob/main/templates/finding.md) · [`status.md`](https://github.com/jcosta33/swarm-starter-kit/blob/main/templates/status.md) — the frozen formats; the board's Human attention list tracks findings pending acceptance.
- [future-cli.md](future-cli.md) — the CLI's design + boundary (the finding scaffold ships as `swarm promote`; a board-mutating close is a non-goal).
- [drift.md](drift.md) — the wider drift model the staleness signal belongs to.
