# Checks fixtures — violations

*Advanced design note — internal rationale; not needed to use Corpus.*

One minimal negative fixture per violation class. Each snippet must be flagged by a
checker applying [`../checks.yaml`](../checks.yaml) — or by a reviewer applying
[the checks reference](../../docs/reference/checks.md) by hand — with exactly the named
check at the named severity. A checker that stays silent on any of these is wrong; so is
one that reports a different check. Inert fixture data — nothing here runs.

---

## V1 — empty paste slot (`non-empty-paste`, hard error)

A task packet's Verify section, every box checked, no output anywhere:

```markdown
## Verify

- [x] `npm test -- export-json.spec.ts` (AC-001)
- [x] `npm run lint` (AC-002)
```

**Expected:** flagged — both items claim completion with no pasted output, no CI link,
and no `n/a` + reason. A claim without visible output is unverified; this is the
hallucinated-completion hole the rule exists to close.

---

## V2 — Pass with an empty Evidence cell (`pass-needs-evidence` / C016, hard error)

A review packet's coverage table:

```markdown
| ID | Result | Evidence | Human attention |
|---|---|---|---|
| AC-001 | Pass |  | no |
```

**Expected:** flagged — an empty Evidence cell means **Unverified**, never **Pass**.
The row's correct content is `Unverified` plus a Human attention entry. Implemented as **C016**
(ADR-0097): the **gate** path (`swarm check <review>`) blocks on it (hard error); the advisory
**reconcile** path (`swarm review`) surfaces the same row id without blocking (ADR-0077 D8).

---

## V3 — `TBD` at `status: ready` (`no-tbd-at-ready` / C007, hard error)

A spec with frontmatter `status: ready` whose Requirements section reads:

```markdown
### AC-001 — Cached repeat queries
When the same query repeats within a session, the search service must return
the cached result.

Verify with: `search-cache.spec.ts`

### AC-002 — TBD (waiting on product)
```

**Expected:** flagged — C007 is a spec check: `ready` means tasks may be cut from this
spec, and a `TBD` requirement hands an agent an undecided behavior. At `status: draft`
the same line is fine. (A `TBD` inside a task packet is caught one step earlier — the
task's scope ids must resolve against the spec, and `AC-002` here resolves to nothing.)

---

## V4 — requirement without a `Verify with:` line (C003 `verify-with`, hard error)

A spec's Requirements section:

```markdown
### AC-003 — rate-limit responses

When a client exceeds 100 requests per minute, the API must return 429.
```

**Expected:** flagged — no `Verify with:` line (SOL form: no `VERIFY BY`). The
verification line is the highest-value line in a spec; without it the requirement can
only ever review as Unverified.

---

## V5 — duplicate requirement ID (C001 `unique-ids`, hard error)

One spec, two headings claiming the same ID:

```markdown
### AC-001 — accept the coupon code

### AC-001 — reject expired coupons
```

**Expected:** flagged — `AC-001` appears twice in one file. Tasks scope work and reviews
report coverage by requirement ID; a duplicated ID makes both ambiguous.

---

## V6 — open blocking question at `closed` (`no-open-critical`, hard error)

A task packet with frontmatter `status: closed` whose Findings section contains:

```markdown
## Findings

- Open question (blocking): should a refresh rotate the whole token family, or
  only the access token? Undecided — AC-002 implemented on a guess.
```

**Expected:** flagged — `closed` is terminal, and a blocking question is still open inside
the packet. The status must stay non-terminal (or the review go to `needs-human`) until
the question is resolved.

---

## V7 — out-of-scope change unflagged (`trigger-coverage`, warning)

A task whose Affected areas list `src/auth/refresh.ts`, reviewed by a packet that says:

```markdown
## Changed files

- `src/auth/refresh.ts`
- `src/billing/invoice.ts`

## Human attention

None — all requirements pass.
```

**Expected:** flagged — `src/billing/invoice.ts` is outside the task's Affected areas
and no Human attention entry routes it. An out-of-scope change is an exception trigger;
the packet must surface it even when every requirement row is green.

---

## V8 — duplicate `id:` across files (C002 `duplicate-id`, hard error)

Two spec files in the same workspace, both claiming the same frontmatter id:

```markdown
<!-- specs/checkout/spec.md -->
---
type: spec
id: SPEC-checkout
---

<!-- specs/checkout-v2/spec.md -->
---
type: spec
id: SPEC-checkout
---
```

**Expected:** flagged — two files claim `SPEC-checkout`, so every cross-reference to that
id is ambiguous. The same check fires when a requirement ID (`AC-NNN`) is reused across
specs.

---

## V9 — two strength words in one requirement (C004 `one-strength-word`, warning)

```markdown
### AC-002 — Expired session response

When the session is expired, the API must return 409 and should log the
session id.

Verify with: `npx jest sessions/expired`
```

**Expected:** flagged — "must … and should …" in one requirement. Two strength words
usually means two requirements; the report recommends a split, it does not perform one.

---

## V10 — missing Non-goals section (C005 `non-goals-present`, warning)

A spec whose sections are Intent · Requirements · Open questions · Affected areas — no
Non-goals heading anywhere in the file.

**Expected:** flagged — the Non-goals section is absent. An empty section under a present
heading fires the same check: it must exist *and* be non-empty.

---

## V11 — missing Open questions section (C006 `open-questions-present`, warning)

A spec whose sections are Intent · Non-goals · Requirements · Affected areas — no Open
questions heading anywhere in the file.

**Expected:** flagged — the section must exist even when it only says "none"; its absence
hides whether ambiguity was resolved or never looked for.

---

## V12 — empty `sources:` (C008 `sources-named`, warning)

```markdown
---
type: spec
id: SPEC-export-json
title: JSON export
status: draft
owner: data-team
sources: []
---
```

**Expected:** flagged — the frontmatter names no origin. A spec with no named source
cannot be checked for fidelity against what was asked.

---

## V13 — named source does not resolve (C009 `broken-source-link`, hard error)

```markdown
---
type: spec
id: SPEC-export-json
sources: [intake/export-json.md]
---
```

…in a workspace whose `intake/` contains no `export-json.md`.

**Expected:** flagged — a workspace path in `sources:` resolves to nothing. A bare
external tracker id (`JIRA-123`) is exempt — naming one at all is C008 territory.

---

## V14 — preserved id resolves nowhere (C010 `preserves-refs-resolve`, hard error)

A change plan whose frontmatter preserves a requirement its source spec never declared:

```markdown
---
type: change-plan
id: CHANGE-sessions-merge
kind: refactor
sources: [SPEC-checkout]
preserves: [SPEC-checkout#AC-099]
---
```

…where `SPEC-checkout` has no `AC-099`, and the plan's guarantee table declares no
`PG-099` either.

**Expected:** flagged — every entry in `preserves:` and the guarantee table must resolve
to a real requirement ID or an explicit plan-local `PG-NNN`. A guarantee pointing at
nothing protects nothing.

---

## V15 — migration plan with no waves (C011 `waves-present`, warning)

A change plan with `kind: migration` whose Transformation waves section is empty:

```markdown
---
type: change-plan
id: CHANGE-api-v2
kind: migration
---

## Transformation waves

(to be planned)
```

**Expected:** flagged — a migration, rewrite, or schema-change plan needs a non-empty
waves section, each wave naming its verify step. A placeholder is not a wave; an
unsequenced migration is the half-migrated codebase waiting to happen.

---

## V16 — run summary missing at `closed` (required section, hard error)

A task packet with frontmatter `status: closed` whose sections end at
`## Findings` — no `## Run summary` anywhere in the file.

**Expected:** flagged — `Run summary` is a required section of the task packet
(checks.yaml `required_sections`). A closed task with no handoff digest leaves
the review packet nothing to read; the Verify pastes hold the evidence, the
summary indexes it.

---

## V17 — a changed file touches a Do-not-change entry (C014 `do-not-change-touched`, warning)

A task whose `## Do not change` lists `src/auth/token-family.ts` (and whose
`## Affected areas` lists `src/auth/`), reviewed by a packet whose `## Changed files`
includes that protected file:

```markdown
## Do not change
- `src/auth/token-family.ts` — the refresh-token family table; rotation logic is frozen.

## Affected areas
- `src/auth/`
```

```markdown
## Changed files
- `src/auth/refresh.ts`
- `src/auth/token-family.ts`
```

**Expected:** flagged — `src/auth/token-family.ts` is named in the task's Do-not-change
list and the review packet reports it changed, so it must be routed to Human attention.
Distinct from V7 (out-of-scope drift): this file lies **inside** the declared Affected
areas (`src/auth/`), so `outsideScope` does not catch it — touching an explicitly
protected path is its own exception. Surfaces a fact, never a verdict.

---

## V18 — coverage gaps against a non-draft spec (C012 `coverage`, warning)

A non-draft spec `SPEC-x` (`status: ready`) defining `AC-001`, `AC-002`, `AC-003`; a task whose
`scope` is `[AC-001, AC-002, AC-003]`; reviewed by a packet whose coverage table omits `AC-003`
and adds a row for `AC-009` (an id the source spec does not define):

```markdown
## Requirement coverage
| ID | Result | Evidence | Human attention |
|---|---|---|---|
| AC-001 | Pass | pasted | no |
| AC-002 | Pass | pasted | no |
| AC-009 | Pass | pasted | no |
```

**Expected:** flagged — `AC-003` is in scope but has no coverage row (**uncovered**), and `AC-009`
names an id absent from the source spec (**orphan**). Scope-guarded to non-draft source specs (a
draft's ids are work-in-progress, mirroring C007's ready gate). Surfaces facts, never a verdict.

---

## V19 — a verify block's cmd disagrees with the named command (C013 `verify-evidence-binding`, warning)

A non-draft spec whose `AC-001` carries `` Verify with: `npm test -- auth-refresh.spec.ts` ``, reviewed
by a packet whose `AC-001` Pass row carries a structured `verify` block (a fenced sibling, info-string
`id=AC-001 cmd="npm test -- other.spec.ts" result=pass`) recording a **different** command.

**Expected:** flagged `cmd-mismatch` — the block's recorded `cmd` does not match the requirement's named
Verify command. The comparison normalizes away surrounding backticks, a trailing `(parenthetical)` note,
and whitespace, so the canon's own backtick-wrapped Verify-with form does **not** false-fire (swarm-hq
#16); only a genuine disagreement trips it. A block whose `cmd` matches and reads `result=pass` is
consistent → no finding; a Pass row with only the free-form Evidence cell stays a warning, never
machine-rejected. A consistency fact, never a verdict.

---

## V20 — a dangling inline citation (C015 `citation-resolves`, warning)

A spec whose frontmatter `sources:` names the workspace `sources.md`, whose `AC-001` makes an
empirical claim citing `[[FAROS2025]]` — a `[[KEY]]` whose key has no `<a id="FAROS2025">` anchor
in that `sources.md`:

```markdown
---
type: spec
id: SPEC-citation-dangle
status: ready
sources:
  - ../../docs/research/sources.md
---

### AC-001 — survey-grounded recommendation
The reviewer must apply the survey's recommended ordering, per [[FAROS2025]].

Verify with: a test.
```

…in a workspace whose `docs/research/sources.md` declares anchors for `GOOGLESA`, `MAST`,
`SMELLS`, … but **no** `<a id="FAROS2025">`.

**Expected:** flagged — `[[FAROS2025]]` resolves to no `<a id>` anchor in the named `sources.md`.
This is the "citations are contextual" discipline made toolable: a load-bearing claim must cite a
verified entry whose anchor exists. Skip-guarded — a spec that names no resolvable `sources.md`, or
cites nothing, is never flagged; the dangle fires only when a `sources.md` is resolvable **and** a
`[[KEY]]` has no matching anchor (v0 = dangling-anchor only). A `[[KEY]]` that resolves (e.g.
`[[GOOGLESA]]` above) is consistent → no finding. Surfaces a fact, never a verdict.

---

## V21 — an orphaned bundled reference (C017 `orphaned-reference`, warning)

A skill guide with a bundled `references/` directory whose `SKILL.md` names one reference and
forgets the other:

```markdown
<!-- .agents/skills/write-spec/SKILL.md -->
# write-spec
Load `references/checklist.md` before you start.
```

…in a skill dir that also holds `references/orphan.md` — a file the `SKILL.md` text names nowhere.

**Expected:** flagged — `references/orphan.md` is bundled but pointed at by no `SKILL.md` line, so
it is dead weight no reader is sent to (the reference-load field test measured that a bundled
resource helps only when the guide loads it). **Orphan direction only**: the named `checklist.md` is
*not* flagged, and the inverse case (a guide naming a reference that does not exist) is out of scope.
Matching is lenient — the bare filename anywhere in the body counts as named — so a guide that does
point at its references never false-fires (measured 0-orphan across the real skills corpus). A
workspace-scope warning; surfaces a fact, never a verdict.
