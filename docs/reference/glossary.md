# Glossary

*Works today — plain markdown plus your agent; no Swarm tooling required.*

One line per term, alphabetical. Where a precise internal term exists for advanced or tooling
contexts, the definition names it; the reverse map is at the bottom.

| Term                          | Definition                                                                                                                                                                                      |
| ----------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **acceptance criterion (AC)** | One verifiable requirement in a spec, labeled `AC-NNN`; the unit a review packet reports a result on.                                                                                           |
| **ADR (decision record)**     | One recorded project decision with its rationale, numbered in `decisions/`.                                                                                                                     |
| **agent run summary**         | The worker agent's closing report, filled in the task packet's `## Run summary` section — changed files, results citing the Verify pastes, candidate findings; the review packet reads it (internally, and in the future CLI: trace). |
| **AGENTS.md**                 | The short, always-loaded context file an agent reads on every task; aim for ~100 lines — Swarm's own convention, nothing enforces it.                                                           |
| **audit**                     | An observation-only report on present-state risk or debt, each observation evidence-grounded; it observes, never prescribes. Advanced artifact.                                                 |
| **bug report**                | The diagnosis of one defect: reliable reproduction, expected vs actual, root-cause evidence. Advanced artifact.                                                                                 |
| **change plan**               | The artifact (`CHANGE-*`) for structural work: what changes, what behavior provably survives, in what order, with rollback criteria.                                                            |
| **checks**                    | Common mistakes to check for, each with a stable ID (`C001`…); in SOL form they extend into the `SOL-XNNN` catalogue. See [checks](checks.md).                                                  |
| **Close**                     | The last step of the loop: merge or block, update the board, save findings.                                                                                                                     |
| **drift**                     | Divergence between a requirement and its implementation after a Pass; when detected, it surfaces as the **Stale** result. See [drift](drift.md).                                                |
| **Dropped from sources**      | The spec section recording what the ticket asked for that the spec deliberately leaves out, and why — intended loss, made auditable.                                                            |
| **evidence**                  | What backs a claim: pasted command output or a CI link, never a bare "tests passed" (internally: proof).                                                                                        |
| **evidence path**             | The files a verification actually exercised on its last Pass; what decides whether a later edit makes that Pass stale.                                                                          |
| **finding**                   | One durable lesson with provenance (`FINDING-*`), saved at Close so the next session doesn't re-learn it (internally, the saving act: promote).                                                 |
| **honesty level**             | The tag every rule carries: convention · checklist · toolable · enforced. The legend lives in [checks](checks.md).                                                                              |
| **intake**                    | The verbatim snapshot of an upstream ticket, issue, or page — preserved uninterpreted so the spec keeps its anchor.                                                                             |
| **inventory**                 | An observation-only map of existing code (`INV-*`) made before brownfield work: modules, interfaces, observed behavior, tests, unknowns.                                                        |
| **isolation mode**           | How a delegated task ran relative to the main checkout — its own **worktree**, the **shared tree**, or **patch-only**; recorded on the task's Provenance line so review can judge attribution.            |
| **multi-repo workspace**     | A dedicated workspace repo governing several code repos: one spec store, one board, one decision ledger; each code repo carries only the three-line footprint (pointer, optional guide, gitignore lines). |
| **non-goals**                 | What a spec deliberately does not change; the section that bounds scope.                                                                                                                        |
| **open question**             | An unresolved item in a spec; a `[blocking]` one keeps the spec out of `status: ready` and holds Close.                                                                                         |
| **owner**                     | The person or team named in spec frontmatter whose say-so changes the spec.                                                                                                                     |
| **preservation guarantee**    | A change-plan row naming a behavior that must not change, with its verification — reuses the spec's requirement ids (plan-local: `PG-NNN`).                                                     |
| **provenance (worker)**       | The optional `## Run summary` line a delegated/worker-run task records — sources read, guide(s) loaded, worker identity, isolation mode; evidence to inspect at review, never a trust token (ADR-0076).        |
| **Pull**                      | The first step of the loop: capture the upstream ask verbatim into an intake file.                                                                                                              |
| **requirement**               | One binding statement of intended behavior, with a `Verify with:` line (internally: obligation).                                                                                                |
| **research**                  | A survey of the options and evidence behind one question; it commits to no decision. Advanced artifact.                                                                                         |
| **review by exception**       | Reading the coverage table and the exception list instead of the whole diff; the packet points your eyes.                                                                                       |
| **review packet**             | The per-task file (`REVIEW-*`): requirement coverage with evidence, the human-attention list, a suggested decision.                                                                             |
| **review result**             | Pass · Fail · Unverified · Blocked, one per requirement row (internally: verdict; lifecycle values Waived, Stale, Contradicted qualify an earlier result).                                      |
| **review stance**             | The role you read with — e.g. the skeptic's refute-by-default (internally: profile). See [review stances](review-stances.md).                                                                   |
| **Run**                       | The loop step where the agent implements the task packet on its own branch and pastes real verification output.                                                                                 |
| **scout**                     | A delegated read/research helper — it gathers, leaves no task packet, and does not merge. Distinct from a **worker** (boots from the packet, owns a write scope, leaves a run summary).                       |
| **six-step loop**             | Pull → Spec → Task → Run → Review → Close, plus the conditional Inventory and Change Plan steps for structural/brownfield work.                                                                 |
| **SOL**                       | The optional structured-requirements notation (`format: sol`): typed blocks, one strength word per requirement, explicit `VERIFY BY` bindings. A notation, not a programming language.          |
| **source authority**          | The rule for which artifact's intent governs when two conflict; code may falsify intent but never silently amend it. See [source authority](source-authority.md).                               |
| **spec**                      | Intended behavior (`SPEC-*`): intent, non-goals, requirements, open questions, affected areas.                                                                                                  |
| **split work**                | Turning a spec or change plan into agent-sized task packets with disjoint scopes (internally: lower / decompose).                                                                               |
| **stance**                    | See review stance.                                                                                                                                                                              |
| **status board**              | `status.md`, the hand-edited workboard; a "done" claim on it links its review packet.                                                                                                           |
| **step**                      | One stage of the loop — Pull, Spec, Task, Run, Review, Close, plus the conditionals (internally: pass; the finer-grained steps live in [the advanced lifecycle](advanced-lifecycle.md)).        |
| **structured requirements**   | The verifiable form of a requirement: in the user tier the plain `AC-NNN` + `Verify with:` shape, optionally tightened into the **SOL** notation. The user-tier name for what SOL notates.                |
| **task packet**               | The bounded work order an agent runs (`TASK-*`): source, scope, do-not-change list, verify commands, agent instructions.                                                                        |
| **verification method**       | The kind of evidence behind a requirement — test, static, contract, property, model, perf, security, manual, monitor (internally: proof type).                                                  |
| **`Verify with:`**            | The line binding a requirement to a runnable check; the highest-value line in a spec.                                                                                                           |
| **watchlist**                 | The advisory list of vague words a requirement line must pair with an observable criterion. The list is in [checks](checks.md).                                                                 |
| **wave**                      | One stage of a change plan; each wave leaves the codebase green and names its verify step.                                                                                                      |
| **workboard**                 | `status.md`, the hand-edited table of open specs, tasks, reviews, and findings — see **status board**.                                                                                          |
| **worker**                    | A delegated agent that boots from a task packet, owns a write scope, and leaves a run summary with provenance; its work merges. Distinct from a **scout** (read/research, no merge).                          |
| **workspace**                 | The small repo holding specs, tasks, reviews, findings, and the board (internally: spec repo). Code repos stay pristine.                                                                        |
| **worktree**                  | A parallel git checkout of the same repo — its own folder and branch — so each task's run stays isolated and parallel tasks never share files.                                                  |
| **writing rules**             | The word-level spec hygiene — one strength word, no vague qualifiers without a pin on the same line (internally: APS). The watchlist is in [checks](checks.md).                                 |

## If you meet the internal term first

Advanced pages and tooling contracts sometimes use the precise internal vocabulary. The map back:

| Internal term          | Everyday term                  |
| ---------------------- | ------------------------------ |
| APS                    | writing rules                  |
| lint code (`SOL-XNNN`) | check                          |
| lower / decompose      | split work                     |
| obligation             | requirement                    |
| pass                   | step                           |
| profile                | review stance                  |
| promote                | save a finding                 |
| proof / proof type     | evidence / verification method |
| spec repo              | workspace                      |
| trace                  | agent run summary              |
| verdict                | review result                  |
| Waived (annotation)    | merged with a recorded waiver (who · which rows · why · expiry) |
| code-repo adapter      | the workspace pointer + gitignore lines a code repo carries — today, nothing else |


## Related

- [Swarm Reference](cheatsheet.md) — the same vocabulary as lookup tables.
- [Artifact formats](artifact-formats.md) — every file type, frontmatter, and required sections.
- [Checks](checks.md) — the check IDs and the writing-rules watchlist.
