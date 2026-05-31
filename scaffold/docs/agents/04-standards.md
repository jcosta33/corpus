# 04 · Writing and execution standards

> **TL;DR.** The framework's voice is **direct, opinionated, and unhedged.** Documents are structured for **progressive disclosure** (TL;DR up top, depth below). Every claim in `## Self-review` is backed by **pasted command output** — verbatim, last 2 lines, raw. The persona's hard constraints are real; the empirical proofs are non-negotiable.

---

## The voice

Direct. Plain declarative statements. Avoid hedge words unless genuinely uncertain. Specific over general; cite the file or section when making a claim. Lead with the load-bearing finding, then explain.

Examples:

- ❌ "We might want to consider potentially looking at the auth module's behaviour."
- ✅ "The auth module's `tokenStore.legacyGet` has 14 callers across `src/auth/`, `src/api/`, `src/jobs/`. The audit recommends migration to `get`."

- ❌ "It would probably be a good idea to add some tests."
- ✅ "Spec AC4 has no test. Add one in `tests/auth/pkce.test.ts:42` covering the `invalid_state` 400 response."

- ❌ "There may be some performance concerns worth investigating."
- ✅ "Profile shows `JSON.parse` consuming 75% of `parseLargeJSON` time. Recommend swapping to `simdjson` (6× speedup measured at 5MB input)."

The framework's tone is the framework's UX. Hedging dilutes the signal.

---

## Progressive disclosure

Every doc supports three reading patterns simultaneously:

| Reader               | Wants                                       | Gets from                                            |
| -------------------- | ------------------------------------------- | ---------------------------------------------------- |
| **30-second skim**   | Core point in one sentence                  | TL;DR / opening paragraph / first heading section    |
| **5-minute read**    | Essentials without tangents                 | Document's structure surfaces them                   |
| **30-minute deep dive** | Full content, organised for drill-down  | Body sections, examples, references                  |

Concretely:

- Every doc opens with a TL;DR or summary capturing the load-bearing claim.
- Every doc has clear hierarchy: high-level → supporting structure → details → examples → references.
- Drill-down content is real and complete — but it lives below the surface, not within it.
- Cross-references replace duplicated detail. Depth lives where it belongs and is referenced from where it's mentioned.

---

## XML-style content tags

Section content that's filled in per-task (rather than read as continuous prose) uses XML-style content tags:

```markdown
## Reliable reproduction

<reliable_reproduction>

**Steps:**
1. ...
2. ...

**Expected:** ...

**Actual:** ...

</reliable_reproduction>
```

This:

- Signals "structured content goes inside" to both human readers and agents
- Makes the boundary clear when the section spans many lines
- Gives a parser something to anchor on (for runners that automate task-file processing)

Used throughout the templates: `<acceptance_criteria>`, `<bug_description>`, `<root_cause>`, `<wave_plan>`, `<worker_tracker>`, `<self_review>`, etc.

---

## Callout markers

| Marker  | Meaning                                                          |
| ------- | ---------------------------------------------------------------- |
| `> ⚠️`  | Warning / heads-up; pay attention                                |
| `> 🔒`  | Locked / read-only constraint (this session must not modify X)   |
| `> 🧪`  | Verification / experimental                                      |
| `> 📚`  | Documentation focus                                              |
| `> 🔧`  | Fix / repair focus                                               |
| `> 🐙`  | Orchestration focus                                              |

These appear in task-file headers above the `> **PERSONA:**` blockquote.

---

## Persona blockquote

A conditioned task file may suggest a persona:

```markdown
> **PERSONA:** Suggested — **The <Name>**. Load `.agents/skills/persona-<slug>/SKILL.md` if one of the eight persona skills fits; otherwise the matching workflow skill carries this mindset.
```

After reading the task file, the agent loads the persona skill when one of the eight (`persona-architect`, `persona-auditor`, `persona-janitor`, `persona-lead-engineer`, `persona-migrator`, `persona-performance-surgeon`, `persona-skeptic`, `persona-surveyor`) matches. For the other five mindsets — Builder, Bug Hunter, Documentarian, Researcher, Test Author — the matching workflow skill (`write-feature`, `write-bug-report`, `write-documentation`, `write-research`, `write-testing`) carries the persona. Lead Engineer ships as `persona-lead-engineer` because orchestration has no *workflow* skill, so its coordination mindset is itself the discipline. The persona is a **suggested default**: when the work in front of you doesn't match, load the skill whose `description` fits and record the divergence in `## Decisions`. Whichever persona is in play, its hard constraints supersede default helpfulness for the entire session.

---

## Open-question markers

Open questions in source docs use two severity markers:

- **`[CRITICAL]`** — would change the doc's content if answered. Block downstream work; the doc halts on these.
- **`[MINOR]`** — worth recording but not blocking. The doc can finalise.

```markdown
## Open questions

- [ ] **[CRITICAL]** Should the auth flow use server-driven or client-driven PKCE? Resolution affects spec §3.4.
- [ ] **[MINOR]** Should we add audit-log emission for `/api/login` failures? Default: yes; defer to implementation.
```

The Architect halts on `[CRITICAL]` open questions before finalising the spec. Other personas similarly halt before declaring `done`.

---

## Assumption markers

Every assumption in a task file's `## Assumptions` section is marked:

- **`[pending]`** — assumed but not yet verified
- **`[confirmed]`** — verified during the session

```markdown
## Assumptions

- [confirmed] The `tokenStore` interface supports the new `storeStateVerifier` method (verified by reading `src/auth/tokenStore.ts:18` and ADR 0017).
- [pending] The `legacyTokenAdapter` shim can be removed in batch 6 — verify by `git grep -c 'legacyTokenAdapter' src/` before deletion.
```

The task file's `## Self-review` hard gate blocks closure if any `[pending]` assumption remains unresolved — it must either be promoted to `[confirmed]` or surfaced as a `## Blocker`. This is enforced by the task structure itself, not by a separate skill.

---

## Empirical proof: Show, Don't Tell

This is the framework's most load-bearing standard. Six rules (codified in `.agents/skills/empirical-proof/SKILL.md`):

### Rule 1: Never assume success

Writing the code is 10% of the job. Verifying it works in *the current environment* is 90%. The agent does not get to assume the test command's output without running it.

### Rule 2: Verbatim pasting

When filling out `## Self-review`, paste the *verbatim* output. No paraphrasing, no summarising, no "✅ passing". Use a fenced code block. Include the last two lines (the runner's summary plus its timing/exit conditions).

### Rule 3: One verification per claim

Each claim — "build passes", "tests pass", "linter clean", "no architectural violations", "migration covers all callsites" — gets its own pasted verification. Bundling claims into a single "all good" hides which check actually ran.

### Rule 4: Re-run after every change

Verifications go stale fast. If the agent makes a change after the verification, the verification is invalid. Re-run; re-paste.

### Rule 5: Run yourself; do not trust upstream

When the Skeptic reviews a worker's branch, the Skeptic runs the project's validation and test commands (`AGENTS.md > Commands > Validation` and `> Test`) *themselves*, in their own worktree, with the worker's branch checked out. The worker's pasted output is *evidence the worker ran the command at some past moment*; it is not evidence the command passes *now in your worktree*.

### Rule 6: Paste, don't quote

Use raw fenced code blocks for output. Do not transform the output (no quoting, no Markdown styling, no annotation in the middle of the paste). Treat the output as data: copy it in, leave it alone.

---

## Halt on Ambiguity

When a source doc is unclear or contradictory, the agent **halts** rather than inventing. The halt is recorded in `## Blockers`:

```markdown
## Blockers

- **Spec ambiguity: collision detection mechanism.** Spec §4.2 says "Return 409 Conflict if an idempotent retry has already produced a payment." Existing `paymentService.create()` returns `null` on idempotent collision; spec doesn't say whether the new endpoint should detect via null-check or via a new throwing API.

  Halting until the Architect updates the spec.
```

Inventing the requirement is the failure mode the spec exists to prevent. Halting is correct; guessing is forbidden.

---

## The Self-review hard gate

Every task template ends with:

```markdown
## Self-review

> **Hard gate.** The task is not complete until every question below has a written answer directly beneath it. An unanswered question is a skipped check.

### Verification outputs (paste actual command output — do not paraphrase)

- `git status` →
- `{{cmdValidate}}` (last 2 lines):
- `{{cmdTest}}` (last 2 lines):

### <persona-specific question 1>
Answer:

### <persona-specific question 2>
Answer:

### Final Polish
- (the standing "what did I leave behind" question)
Answer:

Only when every answer above is written is this task complete.
```

The agent cannot mark `status: done` without filling every answer slot and pasting every verification output. This is the structural defence against hallucinated completion.

---

## Distillation Loss Statement

When a doc is distilled from upstream (research → spec, audit → spec, etc.), append:

```markdown
## Distillation Loss Statement

**Dropped from upstream:**

- <what was dropped, in concrete terms>

**Why downstream doesn't need this:**

- <justification>
```

A reviewer reads upstream and downstream side by side; the Loss Statement makes verifying nothing load-bearing went missing easy.

See `.agents/skills/distillation-discipline/SKILL.md` for the full discipline.

---

## See also

- `01-process.md` — the documentation-first workflow
- `02-file-types.md` — what each document type contains
- `03-workflow.md` — step-by-step session flow
- `05-flow-graph.md` — the recommended routing graph
- `.agents/skills/empirical-proof/SKILL.md` — Show-Don't-Tell discipline
- `.agents/skills/distillation-discipline/SKILL.md` — Loss Statement protocol
