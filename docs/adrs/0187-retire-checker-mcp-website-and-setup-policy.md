---
type: adr
id: adr-0187
status: accepted
created: 2026-11-05
---

# ADR-0187 - Retire the checker, MCP server, website, and setup policy

## Context

[ADR-0140](./0140-skills-are-the-product-tools-reinforce.md) made the skills the product. The CLI,
the MCP server, and the checks contract were kept to reinforce them.
[ADR-0165](./0165-checker-invocation-architecture.md) kept the skills checker-agnostic, and no skill
ever needed a tool to run.

On 2026-11-04 the owner deleted the `suspec-cli`, `suspec-mcp`, `suspec-website`, and
`suspec-starter-kit` repositories. After that, this repository still described those surfaces as
live:

- The checks contract and its fixtures under `checks/`.
- The CLI reference, the setup-target and native-policy chain ending in `policy/agent.md`, and the
  integrations, adoption, tutorial, and example pages.
- `scripts/lint-method-topology.sh`, which resolved the deleted CLI to run, so `lint-all.sh` failed.

Usage on the owner's machine showed no checked artifact. None of the task files under
`~/.agents/artifacts` matched the task format the checker enforced.

## Decision

1. **The product is the skills and the method.** Corpus claims to be standalone skills that write
   durable, evidence-bound working artifacts. It makes no deterministic-checking claim.
2. **The checker retires.** `checks/`, the checks reference, the local-checks reference, and every
   C-numbered rule retire with the CLI that executed them. Artifact shapes are stated by
   the human-facing formats reference and by each artifact-author skill.
3. **The MCP server retires.** No tool discovers, checks, or resolves artifacts.
4. **The website and starter kit retire.** The README and `docs/` are the only documentation.
5. **Setup and the native agent policy retire.** `policy/agent.md` and every setup target leave the
   repository. A harness's own instruction file belongs to its owner, and Corpus installs nothing
   into it.
6. **Gates shrink to what this repository owns.** `scripts/lint-all.sh` runs the ADR seal, the
   artifact-author skill gate, and the ADR-range guard. The method-topology, product-citation,
   count-range, and skill-gate self-test scripts retire, along with the docs that described them.
7. **Evidence rules survive as method.** A completion claim still binds to directly inspectable
   output, and work still does not close on an open blocking question. A reviewer applies these
   rules. No tool enforces them.

## Superseded decisions

Each of these decided a checker rule, a CLI or MCP behavior, or a setup target that no longer
exists.

- [ADR-0070](./0070-checks-directory-rename.md): `checks/` is the home of the checks contract
- [ADR-0077](./0077-suspec-cli-reconcile-only-harness.md): suspec-cli is a reconcile-only harness of composable parts
- [ADR-0078](./0078-c002-exempts-draft-specs.md): C002 (duplicate-id) exempts draft specs from cross-spec requirement-id reuse
- [ADR-0079](./0079-c012-coverage-check.md): C012 (coverage): mint the deterministic review-coverage check
- [ADR-0081](./0081-kit-provenance-stamp.md): Re-adopt the kit provenance stamp (narrow reversal of ADR-0050 §6)
- [ADR-0084](./0084-boundary-safe-prepare-verbs.md): Boundary-safe prepare verbs; narrow the board-mutating close to scaffold-only
- [ADR-0085](./0085-suspec-mcp-adapts-the-json-contract.md): suspec-mcp adapts the CLI's `--json` contract (shells out), not the core library
- [ADR-0086](./0086-deterministic-review-scanning-decision.md): Deterministic review scanning is the shipped reconcile wedge: accept C014, gate the measurement track, reject the off-boundary asks
- [ADR-0087](./0087-citation-anchor-check.md): Mint C015 `citation-resolves`: the inline `[[KEY]]` anchor check (toolable, fact-not-verdict, measured before shipping)
- [ADR-0091](./0091-suspec-update-check.md): `suspec update`: a reconcile-only kit refresh — ship `--check`, defer the merge
- [ADR-0097](./0097-mint-c016-c017-defer-oversized.md): Mint C016 (pass-needs-evidence) + C017 (orphaned-reference); the oversized-packet band is specified-not-shipped (measured)
- [ADR-0107](./0107-fast-track-staleness-detection.md): Fast-track solo review via staleness detection, not an agent verdict
- [ADR-0126](./0126-c004-at-least-one-strength-word.md): C004 softens to at-least-one strength word; more-than-one becomes a split-candidate advisory (contract 0.12.0)
- [ADR-0127](./0127-c004-exempts-interface-blocks.md): C004 exempts SOL INTERFACE (IF-) blocks — a signature declaration has no strength-word slot (contract 0.13.0)
- [ADR-0128](./0128-mint-c020-unresolvable-ref.md): Mint C020 `unresolvable-ref` — a review whose named task/spec ref does not resolve hard-errors at the gate instead of silently passing (contract 0.14.0)
- [ADR-0129](./0129-c013-cmd-mismatch-blocks-at-gate.md): C013 cmd-mismatch blocks at the gate face; other faces + reconcile stay advisory (contract 0.15.0)
- [ADR-0130](./0130-review-staleness-content-drift.md): Review staleness also flags a reviewed file that drifts in content since `reviewed_sha` (reconcile-only, no contract bump)
- [ADR-0136](./0136-launcher-boundary-automate-not-agent.md): The launcher boundary: suspec-cli automates the loop (worktree, setup, lean transient prompt, launch, record, reconcile) but is not the agent — it becomes one only if it runs the model loop, authors the verdict, semantically rewrites an artifact, or owns multi-agent merge
- [ADR-0143](./0143-path-agnostic-check-cli-contract.md): Path-agnostic check is the entire CLI contract: `suspec check <artifact> [--spec <path>] [--task <path>]` + `suspec check --contract`; no resolution of any kind beyond C010's sibling-spec scan; a missing required companion blocks; C009/C010/C015 resolve artifact-relative; C017 leaves the adopter contract (contract 0.16.0)
- [ADR-0153](./0153-mcp-parity-and-compatibility.md): Multi-path MCP checking, exact runtime compatibility, and a lean response envelope
- [ADR-0172](./0172-reversible-harness-economy-setup.md): Explicit reversible user-level economy setup with no MCP expansion
- [ADR-0173](./0173-native-harness-instruction-installation.md): Native inline economy installation without branded user-home scaffolding
- [ADR-0174](./0174-fixed-native-instruction-targets.md): Fixed normal global instruction targets; shadowing configuration blocks setup
- [ADR-0175](./0175-single-context-gateway.md): One native agent policy, one context gateway, and matching Codex, Claude Code, Kimi Code, ZCode, and OpenCode targets
- [ADR-0177](./0177-agent-policy-provenance-and-upgrade-integrity.md): Retained policy provenance, canonical-byte verification, and reversible payload upgrades
- [ADR-0185](./0185-cursor-and-antigravity-setup-targets.md): Cursor and Antigravity join explicit setup targets

## Narrowed decisions

Each of these keeps its method content. Only the clauses that name the checker, the CLI, the MCP
server, the starter kit, or setup lose force.

- [ADR-0062](./0062-code-repo-adapter.md): Code-repo adapter: pristine today, gitignored CLI state when a CLI exists
- [ADR-0063](./0063-honesty-framework-and-tooling-boundary.md): The honesty framework and the tooling boundary
- [ADR-0066](./0066-checks-redefinition.md): Checks: the adopter validity bar and the producer-internal reference values
- [ADR-0074](./0074-repo-family-split.md): The repo family realized: producer workspace and skills catalog
- [ADR-0080](./0080-spec-scoped-requirement-ids.md): Requirement ids are spec-scoped, not workspace-global
- [ADR-0083](./0083-verify-evidence-reconcile.md): The structured-evidence format: binding a requirement's named Verify command to its recorded result
- [ADR-0088](./0088-delegation-provenance.md): Delegation provenance: a reviewable trace when an agent delegates to a subagent (neutral contract, runner-specific producers, fact-not-verdict)
- [ADR-0090](./0090-c015-tier-checks-deferred.md): C015 tier-checks stay deferred: no high-precision form exists pre-measurement; the Rejected case is already covered by an invariant
- [ADR-0094](./0094-decomposition-and-risk-weighted-review.md): Decomposition into small untangled units; review scrutiny weighted by diffusion, churn, and change-type
- [ADR-0096](./0096-artifact-lifecycle.md): Artifact lifecycle at scale: durable-vs-ephemeral records, status + supersede, retention, freshness, and anti-duplication
- [ADR-0110](./0110-execution-change-record.md): The `## Execution` entry is a structured change-record (a durable evidence digest)
- [ADR-0113](./0113-product-vs-docs-boundary.md): Citations live in docs, not in products (the product-vs-docs boundary)
- [ADR-0116](./0116-shipped-spec-invariant.md): Shipped-spec invariant + status/spec coherence check
- [ADR-0125](./0125-remint-c019-malformed-requirement-heading.md): Re-mint `malformed-requirement-heading` as C019; the C018 oversized-packet reservation stands (contract 0.11.0)
- [ADR-0134](./0134-self-contained-spine.md): Suspec's self-contained spine: the mandatory triad (spec→run→close; intake/task/review optional), artifacts-are-the-glue (a review reconciles against the spec, never the task), and skills/tools are additive accelerators — no canonical part depends on an optional one; the assumed floor is a capable harness (spawn a subagent for independent review); automated checks are early-warning, never a replacement
- [ADR-0137](./0137-personal-harness-transient-artifacts.md): Suspec is a personal harness: transient artifacts at `~/.claude/state/<repo>/`, repo-root execution, durability by promotion (ADRs/tests/issues/PR digests), globally installed skill family, no committed workspace/board/`.suspec/`
- [ADR-0138](./0138-retire-the-starter-kit.md): Retire the starter kit entirely: `suspec init` seeds the repo from scaffolds embedded in the CLI, the skill family installs globally, artifact shapes live in the CLI's built-in scaffolds + the checks contract (human-facing reference: `docs/reference/artifact-formats.md`); `suspec update` + the kit-manifest machinery retire with it
- [ADR-0140](./0140-skills-are-the-product-tools-reinforce.md): Suspec v3: the methodology ships as skills, first-class; CLI/MCP/checks reinforce; Suspec coexists with native plan mode; proportional rigor is doctrine; checks advise — no gate command; adopters commit no Suspec artifacts
- [ADR-0141](./0141-artifacts-beside-native-artifacts.md): Artifacts live beside the agent's native artifacts: skills describe placement, the agent chooses the spot, paths flow explicitly; the store and its management machinery retire
- [ADR-0144](./0144-keys-and-scaffold.md): Keys and scaffold: intent · review · findings are the keys — present on virtually every change at whatever weight it earns; the spec, task split, inventory, change plan, and checker are scaffold pulled in when the work earns them; keys-and-scaffold replaces mandatory-vs-optional as doctrine and vocabulary; the seal reads hexagon = the loop, triangle = the keys
- [ADR-0145](./0145-attention-economy-and-decision-rails.md): Disrespec, structured human decisions, agent evidence assessment, lean artifact shapes, and evidence receipts
- [ADR-0152](./0152-deterministic-contract-tightening.md): Strict frontmatter, explicit artifact types, direct task checks, and an honest deterministic catalog
- [ADR-0154](./0154-spec-backed-tasks-and-review-closure.md): Spec-backed tasks, visible evidence forms, and mechanically closed review decisions
- [ADR-0157](./0157-ruthless-skills-and-closed-artifact-authorship.md): Ruthless economical skill prose, universal ambiguity forks, closed artifact authorship, and sequential inspection repair
- [ADR-0158](./0158-deterministic-artifact-binding.md): Spec shape, review-to-spec binding, receipt resolution, and non-waivable preservation coverage
- [ADR-0159](./0159-companion-and-task-binding.md): Explicit task-source binding, valid review companions, and checked dependency handoff
- [ADR-0164](./0164-one-spec-format.md): One spec format: structured markdown (`### AC-NNN` + `Verify with:`); the `format: sol` selector and the SOL surface retire
- [ADR-0165](./0165-checker-invocation-architecture.md): CLI engine, ambient MCP discovery, checker-agnostic skills, and optional invocation
- [ADR-0166](./0166-enriched-single-spec-format.md): One enriched Markdown requirement block with deterministic shape and exact modal checks
- [ADR-0171](./0171-global-interaction-economy.md): Global interaction economy without method leakage or recap
- [ADR-0176](./0176-native-delivery-control-contract.md): Advisory Suspec methods, project-native delivery enforcement, harness isolation, and human authority
- [ADR-0178](./0178-restartable-campaign-goals.md): Stable campaign goal contracts, project-native progress, restart-safe execution, and deterministic campaign checks
- [ADR-0181](./0181-evidence-settled-decisions-and-bounded-panels.md): Evidence-settled technical decisions and bounded independent panels
- [ADR-0184](./0184-two-doors-drill-native-review.md): Drill, native independent review, delete the review packet
- [ADR-0186](./0186-artifact-authors-ship-with-canon.md): Artifact authors ship with canon, universal methods leave the family, panel stops being an artifact

## Consequences

- Delivery control in this repository is the CI run of `scripts/lint-all.sh`. Any artifact rule
  beyond the skills' own text is advisory.
- A `C0NN` code in an ADR body is historical. No tool emits it.
- Installs pinned to the deleted repositories fail. The skills install with `npx skills add`
  alone.
- Adopters who ran setup keep whatever it wrote into their harness files. Corpus no longer
  maintains it, and removing it is the owner's call.

## Status

Accepted (2026-11-05). Supersedes and narrows the decisions listed above.
