# Memory INDEX

> Tier-1 of the memory model (§23.1) — the compact recall map an agent reads *first* and *cheaply*. This is
> **a map of links, not explanations**: it links into the Tier-2 evidence store (`finding.md`, `patterns/*.md`,
> and the rest of §23.2) and MUST NOT duplicate their bodies. Markdown-only, no runtime — this file is the
> contract a future recall tool builds against, not a retrieval engine.
>
> **Load-when discipline (§23.1.1, normative):** every entry MUST carry a `Load when` condition — the trigger
> that tells a future agent the entry is relevant to its current task. If an entry cannot name *when it matters*,
> remove it: an entry without a usable `Load when` is dead weight against the §24 loss budget and the §31
> density cap.
>
> A conformant tool MAY treat a divergence between a summary line here and the linked Tier-2 artifact as
> advisory drift. The companion `memory/glossary.md` (§23.1.2) holds term definitions; this file holds the
> recall map only.

## Durable findings

<one row per promoted/accepted `finding.md` in the Tier-2 store; `Status` mirrors the finding's status enum
(§23.4 / §23.5: `candidate | accepted | promoted | rejected | stale`); `Load when` mirrors the finding's
`applies_when` scope envelope (§23.3). Link the file, do not restate its claim.>

| Finding | Status | Load when |
| -------------------------------- | -------- | ------------------------------------------------------ |
| {{finding-file.md}} | {{status}} | {{when this finding is relevant to the task at hand}} |
| {{finding-file.md}} | {{status}} | {{when this finding is relevant to the task at hand}} |

## Topic files

<one row per `patterns/*.md` or other Tier-2 topic artifact (§23.2); a pattern distils ≥2 corroborating
findings and cites them. Link the file; `Load when` names the trigger that surfaces it.>

| Topic | File | Load when |
| --------------------- | -------------------------- | ------------------------------------------------------ |
| {{topic name}} | `{{patterns/topic.md}}` | {{when this topic is relevant to the task at hand}} |
| {{topic name}} | `{{patterns/topic.md}}` | {{when this topic is relevant to the task at hand}} |
