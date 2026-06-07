# specs/

Your specs live here — the intent a spec repo authors and reviews, and the thing agents build from. **Each
feature is a folder:** `specs/<NNN-feature-slug>/`, holding the contract `spec.swarm.md` (plain Markdown
carrying SOL obligations) **plus any of its feature-scoped supporting docs beside it** — `audit.md`,
`research.md`, `bug-report.md`, `prd.md`, `rfc.md`, `threat-model.md`, `review.md`. Co-locating a feature's
evidence with its contract is the point: the requirement→evidence trail is one folder, not a cross-repo hunt.

```text
specs/
  001-contact-form/        # ← the example: rename/replace it
    spec.swarm.md          #    the contract (the SOL obligations)
    research.md            #    a co-located supporting doc
  002-your-next-feature/
    spec.swarm.md
```

A pre-spec input (a research note or audit with no spec yet) simply starts the feature folder it explores.
**Project-wide decisions** (ADRs) live in top-level `decisions/`, not here. **Durable findings** live in
`.agents/memory/`. `.agents/` holds only the Swarm tooling (skills, reference cards, templates, memory).
