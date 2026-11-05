# ADR-0187 classification

Scope: each candidate ADR's body (Decision, plus Context and Consequences where needed) and its ledger row in `docs/adrs/README.md`, read against ADR-0187, which retires the checker, the MCP adapter, the website, and the setup policy. Paths are relative to `/Volumes/Development/suspec/docs/adrs/`, and README line numbers refer to the ledger.

Rules applied:
- Superseded by 0137, 0141, 0151 or 0138: these chains stand, so the ADR is `none`.
- Superseded or narrowed only by 0143: 0143 is the CLI contract and dies with 0187. The ADR is therefore classified on its own content.
- A clause that only says no CLI or MCP surface is added counts as incidental.

Added from the ledger scan: rows tagged `canon -> CLI` or `-> MCP` that were not in the candidate list. These are 0145 (`canon → skills/agents/cli/mcp`, README:179) and 0157 (`canon -> skills/CLI/MCP`, README:191). Candidates 0091 and 0097 also carry `canon → cli`. No other row matched.

| ADR | Title | Current ledger disposition | Classification | Reason | Decisive `file:line` |
| --- | --- | --- | --- | --- | --- |
| 0061 | Intake artifact and the Pull step | New; workspace clauses retired by 0137; narrowed by 0151 | none | `suspec pull` is named only as a future-CLI deferral; the intake/verbatim decision is method | 0061-intake-artifact.md:26 |
| 0062 | Code-repo adapter | New; narrowed by 0137 | none | The CLI `.suspec/` state clause was already retired by 0137, which stands (0137-personal-harness-transient-artifacts.md:101); "never dirty a product repo" survives | 0062-code-repo-adapter.md:25 |
| 0063 | Honesty framework and tooling boundary | New (refines 0023/0026/0034/0043/0055) | narrowed | The honesty levels and checklist framing survive; D3 "suspec-cli is the reference implementation" and the `suspec spec check` contract die | 0063-honesty-framework-and-tooling-boundary.md:35 |
| 0064 | Minimal starter kit tiering | New; framing superseded by 0069; tiers dropped by 0105; 0137 | none | The kit is already retired (0138); `suspec init` appears only as a future third adoption path | 0064-minimal-kit-tiering.md:38 |
| 0066 | Checks: adopter validity bar | New; 0070 rename; 0071; 0137; narrowed by 0152 | narrowed | Evidence rules (non-empty-paste, no-open-critical) survive; the validity bar keyed to checks.md and the fixtures consumed by suspec-cli die | 0066-checks-redefinition.md:24 |
| 0069 | Starter kit copied whole | Superseded by 0137 | none | Already superseded by the standing 0137 chain | README.md:103 |
| 0070 | `checks/` is the home of the checks contract | New (refines 0066) | superseded | Its only subject is the `checks/` directory and `checks.yaml` | 0070-checks-directory-rename.md:23 |
| 0073 | Multi-repo workspace | Superseded by 0137 | none | Already superseded by the standing 0137 chain | README.md:107 |
| 0074 | Repo family realized | Superseded by 0137 | none | Already superseded by the standing 0137 chain | README.md:108 |
| 0076 | Worker provenance and adoption conventions | New; workspace clauses retired by 0137 | none | Method conventions; `suspec init/check` appears only as a "should enforce" level label and in propagation | 0076-worker-provenance-and-adoption-conventions.md:101 |
| 0077 | suspec-cli is a reconcile-only harness | New; narrowed by 0137 and 0143 | superseded | Every decision describes suspec-cli's engines, contract, MCP server and boundary | 0077-suspec-cli-reconcile-only-harness.md:32 |
| 0078 | C002 exempts draft specs | New; subsumed by 0080 | superseded | A rule about check C002 only | 0078-c002-exempts-draft-specs.md:30 |
| 0079 | C012 coverage check | New; upheld by 0143 | superseded | Mints check C012 only; coverage-keying method lives in 0103/0134 | 0079-c012-coverage-check.md:29 |
| 0080 | Requirement ids are spec-scoped | New (supersedes part of 0078) | narrowed | Spec-scoped ids and the `SPEC-x#AC-NNN` form survive (artifact-formats.md:233); the C002 clause and checkWorkspace edits die | 0080-spec-scoped-requirement-ids.md:36 |
| 0081 | Kit provenance stamp | New; workspace clauses retired by 0137 | superseded | The stamp is written by `suspec init` into the already-retired kit; nothing survives | 0081-kit-provenance-stamp.md:27 |
| 0083 | Structured-evidence `verify` format | New; upheld by 0143; narrowed by 0145 | narrowed | The spot-check rule and "consistency, not ground truth" survive; C013 and the parser-matched severity split die | 0083-verify-evidence-reconcile.md:136 |
| 0084 | Boundary-safe prepare verbs | Superseded by 0143 | superseded | The superseding 0143 dies; subject is only the CLI verbs `pull`/`promote` | 0084-boundary-safe-prepare-verbs.md:28 |
| 0085 | suspec-mcp adapts the CLI `--json` | New; narrowed by 0143 and 0153 | superseded | Subject is only the MCP adapter architecture | 0085-suspec-mcp-adapts-the-json-contract.md:23 |
| 0086 | Deterministic review scanning, C014 | New; narrowed by 0152 | superseded | Subject is the `suspec review` wedge, C014 and CLI non-goals | 0086-deterministic-review-scanning-decision.md:53 |
| 0087 | Mint C015 citation-resolves | New | superseded | Mints check C015 only | 0087-citation-anchor-check.md:27 |
| 0088 | Delegation provenance trace | New (canon → cli/kit) | narrowed | The neutral record-not-verdict trace contract survives; Producer 1 (`suspec run --agent` run-record) dies | 0088-delegation-provenance.md:47 |
| 0089 | Decision handoff `## Open decisions` | New (canon → kit) | none | Method convention; ADR-0077 D8 is cited only as context | 0089-decision-handoff-open-decisions.md:54 |
| 0090 | C015 tier-checks deferred | New (canon) | narrowed | "Rejected entries carry no anchor" survives (docs/research/sources.md:621) and the Caveated-MUST review checklist stays; the C015 deferral dies | 0090-c015-tier-checks-deferred.md:40 |
| 0091 | `suspec update --check` | New (canon → cli); 0137 | superseded | A CLI verb only (the kit refresh) | 0091-suspec-update-check.md:35 |
| 0092 | suspec-agents member | New; narrowed by 0151 | none | Subject is the agent catalog (narrowed by 0151); `suspec run` is named only as context | 0092-suspec-agents-member.md:57 |
| 0093 | Collapse 1:1 personas | New (canon → catalog/kit/website) | none | Catalog decision; no CLI/MCP/website clause in the Decision | 0093-collapse-1to1-personas.md:34 |
| 0094 | Decomposition and risk-weighted review | New; oversized check is a suspec-cli follow-up | narrowed | The decomposition and review-weighting rules survive; D2's oversized-packet `suspec check` signal dies | 0094-decomposition-and-risk-weighted-review.md:50 |
| 0095 | Review model grounding | New (canon → docs/suspec-agents) | none | Method; the suspec-cli reconcile is cited only as an existing realization | 0095-review-model-grounding.md:59 |
| 0096 | Artifact lifecycle | New; amended by 0104; narrowed by 0137 | narrowed | The supersede/single-sourcing lifecycle survives; D2's specified `suspec check` supersede-pointer check dies | 0096-artifact-lifecycle.md:52 |
| 0097 | Mint C016/C017; oversized deferred | New (canon → cli); narrowed by 0143 and 0152 | superseded | Check mints C016/C017, the C018 reservation and `suspec review` size facts only | 0097-mint-c016-c017-defer-oversized.md:26 |
| 0098 | Codex emitter and universal layer | New; narrowed by 0143 and 0151 | none | The CLI emitter was also retired by the standing 0151 ("custom projections retire"); the remaining subject is the agents layer | README.md:132 |
| 0099 | Review orchestration and role routing | New; narrowed by 0151 | none | Method; ADR-0077 D8 is cited only for the verdict | 0099-review-orchestration-and-role-routing.md:67 |
| 0100 | Spec-external, ops-local | Superseded by 0137 | none | Already superseded by the standing 0137 chain | README.md:134 |
| 0101 | Open decisions carry options | New (canon → kit) | none | "checked by C006" is incidental (C006 already retired by 0145) | 0101-authoring-open-decisions.md:25 |
| 0103 | Spec is a living form; task on demand | New; narrowed by 0137 | none | Method; the suspec-cli reconcile is only a tracked follow-up | 0103-spec-as-living-form-task-on-demand.md:54 |
| 0106 | Keep-clean tooling | Superseded by 0141 | none | Already superseded by the standing 0141 chain | README.md:140 |
| 0107 | Fast-track via staleness detection | Superseded by 0143 | superseded | The superseding 0143 dies; subject is the `suspec check` hash re-validation on the (deleted) review packet | 0107-fast-track-staleness-detection.md:25 |
| 0110 | `## Execution` structured change-record | New; narrowed by 0143 | narrowed | Scope/Coverage survive; Pins (`suspec stamp`) and the reconcile advisory die, and their retirement was owned by the dying 0143 | 0110-execution-change-record.md:27 |
| 0111 | Kit skills are Suspec concepts | New; narrowed by 0140 | none | No CLI/MCP clause | 0111-kit-skill-scope.md:23 |
| 0112 | Two-tier skills | New; narrowed by 0140 | none | No CLI/MCP clause | 0112-two-tier-skills.md:9 |
| 0113 | Citations live in docs, not products | New (canon → all repos) | narrowed | The no-citation product-body rule survives for skills; the suspec-mcp tool-string and CLI-README surfaces die | 0113-product-vs-docs-boundary.md:21 |
| 0114 | Retired-artifact registry | Superseded by 0151 | none | Already superseded by the standing 0151 chain | README.md:148 |
| 0115 | Synced catalogs links or gated | New; 0137; narrowed by 0186 | none | No CLI/MCP clause (the freshness check is a CI diff) | 0115-synced-catalogs-links-or-gated.md:56 |
| 0116 | Shipped-spec invariant | New (canon → cli); narrowed by 0137 | narrowed | The spec-status↔Execution coherence invariant stands per 0137 (0137-personal-harness-transient-artifacts.md:108); the `suspec check` implementation dies | 0116-shipped-spec-invariant.md:37 |
| 0117 | No count-bearing prose | New; narrowed by 0155 | none | No CLI/MCP clause | 0117-no-count-bearing-prose.md:56 |
| 0119 | Independent review invariant | New (canon → docs/site); narrowed by 0184 | none | Method; "site" is only a propagation tag and ADR-0077 is cited only as context | 0119-independent-review-invariant.md:29 |
| 0121 | Evidence-gating load-bearing | New; upheld by 0140 | none | Names no tool; the suspec-cli reconcile appears only in its level note | 0121-evidence-gating-load-bearing-mechanic.md:68 |
| 0124 | Per-lens cost-tier routing | New | none | No CLI/MCP clause | 0124-opt-in-per-lens-cost-tier-routing.md:37 |
| 0125 | Re-mint C019; C018 reserved | New (contract 0.11.0) | narrowed | The only ADR body stating "a split requirement gets its own number, never a suffix" (method); C019/C018 die | 0125-remint-c019-malformed-requirement-heading.md:32 |
| 0126 | C004 at-least-one strength word | New (contract 0.12.0) | superseded | Semantics of check C004 only (the binding-word rule now lives in 0166 D1/format) | 0126-c004-at-least-one-strength-word.md:23 |
| 0127 | C004 exempts SOL INTERFACE | New (contract 0.13.0) | superseded | Applicability of check C004 only; SOL already retired by 0164 | 0127-c004-exempts-interface-blocks.md:25 |
| 0128 | Mint C020 unresolvable-ref | New; narrowed by 0143 and 0184 | superseded | Mints check C020 only | 0128-mint-c020-unresolvable-ref.md:26 |
| 0129 | C013 blocks at the gate face | New; narrowed by 0143 | superseded | Severity of check C013 only | 0129-c013-cmd-mismatch-blocks-at-gate.md:30 |
| 0130 | Review staleness content drift | Superseded by 0143 | superseded | The superseding 0143 dies; subject is only the `suspec review` Stale predicate | 0130-review-staleness-content-drift.md:25 |
| 0134 | Self-contained spine | New; narrowed by 0144, 0149, 0184 | narrowed | The artifact glue and by-hand path survive; the D3/D4 CLI/MCP accelerator and early-warning clauses die | 0134-self-contained-spine.md:42 |
| 0135 | Kit manifest; CLI reads it | Superseded by 0138 | none | Already superseded by 0138, whose kit retirement stands | README.md:169 |
| 0136 | Launcher boundary | Superseded by 0143 | superseded | The superseding 0143 dies; subject is only what suspec-cli may automate | 0136-launcher-boundary-automate-not-agent.md:33 |
| 0137 | Suspec is a personal harness | New; narrowed by 0138/0139/0141/0142/0186 | narrowed | Transient artifacts and the global skill family survive; D1 "linted by the deterministic checks contract" and the CLI families die | 0137-personal-harness-transient-artifacts.md:43 |
| 0138 | Retire the starter kit | New; narrowed by 0140 | narrowed | The kit retirement survives; D3/D5 (artifact shapes = CLI scaffolds plus the checks contract) die | 0138-retire-the-starter-kit.md:47 |
| 0139 | Store location rule | Superseded by 0141 | none | Already superseded by the standing 0141 chain | README.md:173 |
| 0140 | Skills are the product; tools reinforce | New; narrowed by 0144/0151/0172 | narrowed | D1/D3/D4/D6 survive; D2 (CLI/MCP/checks contract) and D5 (checks advise at check time) die | 0140-skills-are-the-product-tools-reinforce.md:44 |
| 0141 | Artifacts beside native artifacts | New; narrowed by 0148 | narrowed | Paths flow explicitly (survives); D3's checker-paths clause and the C009/C015/C010 sibling exception die | 0141-artifacts-beside-native-artifacts.md:42 |
| 0142 | Findings become native memories | New | none | "no promote verb" is a negation and incidental | 0142-findings-become-native-memories.md:33 |
| 0143 | Path-agnostic check is the CLI contract | New; narrowed by 0153/0172/0184 | superseded | The entire decision is the `suspec check` surface | 0143-path-agnostic-check-cli-contract.md:27 |
| 0144 | Keys and scaffold | New; narrowed by 0151, 0184 | narrowed | Keys and scaffold survive; "the deterministic checker" as scaffold, the "site" vocabulary surface and the hexagon's check node die | 0144-keys-and-scaffold.md:40 |
| 0145 | Disrespec, decision rails, receipts (added) | New (canon → skills/agents/cli/mcp); narrowed by 0149/0150/0157/0158/0171 | narrowed | Economy, decisions, assessment and receipts survive; D3's C005/C006/C007 clauses die | 0145-attention-economy-and-decision-rails.md:37 |
| 0152 | Strict frontmatter, closed types, catalog | New (canon -> CLI); narrowed by 0154/0157/0158/0159 | narrowed | The closed `type:` set survives (artifact-formats.md:31); contract 0.18.0, the checker faces and C014/C021–C024 die | 0152-deterministic-contract-tightening.md:19 |
| 0153 | Multi-path MCP checking | New (canon -> MCP); narrowed by 0157/0158/0159/0184 | superseded | Only the MCP adapter | 0153-mcp-parity-and-compatibility.md:19 |
| 0154 | Spec-backed tasks; review closure | New (canon -> skills/CLI); narrowed by 0157/0158/0159/0184 | narrowed | "Every task is spec-backed" survives; the C023/C024 forms and contract 0.18.0 die | 0154-spec-backed-tasks-and-review-closure.md:23 |
| 0157 | Ruthless skills; closed authorship (added) | New (canon -> skills/CLI/MCP); narrowed by 0158/0184/0186 | narrowed | D1–D4 and D6 survive; D5 (contract 0.19.0 type handling) dies | 0157-ruthless-skills-and-closed-artifact-authorship.md:35 |
| 0158 | Spec shape, review binding, receipts | New (canon -> skills/CLI/MCP); narrowed by 0159/0184 | narrowed | Change-plan preservation coverage must be Supported, and the spec shape survives in format; C025–C027 and contract 0.20.0 die | 0158-deterministic-artifact-binding.md:28 |
| 0159 | Task-source binding; dependency handoff | New (canon -> skills/CLI/MCP); narrowed by 0184 | narrowed | `Run order` with Starts after/May run with survives (artifact-formats.md:94); `--spec` binding, contract 0.21.0 and MCP forwarding die | 0159-companion-and-task-binding.md:22 |
| 0164 | One spec format | New (canon -> cli/mcp/skills) | narrowed | One markdown format with no SOL survives; D4 (C004) and D5 (contract 0.22.0) die | 0164-one-spec-format.md:36 |
| 0165 | CLI engine, MCP discovery, checker-agnostic skills | New (canon -> skills/mcp); narrowed by 0172 | narrowed | D3 "skills state required shape and self-checking method" survives; D1/D2/D4/D5 (CLI, MCP) die | 0165-checker-invocation-architecture.md:29 |
| 0166 | Enriched requirement block | New (canon -> cli/mcp/skills) | narrowed | The When/Then/Verify-with block, `When: always`, no block types and proportional rigor survive; C028, C004, C003/C013 and contract 0.23.0 die | 0166-enriched-single-spec-format.md:33 |
| 0171 | Global interaction economy | New (canon -> skills/CLI) | narrowed | D2–D6 economy principles survive in skills (link-only handoff); D1 installed `policy/economy.md` dies | 0171-global-interaction-economy.md:26 |
| 0172 | Reversible economy setup | New (canon -> CLI); narrowed by 0173 | superseded | Only `suspec setup` | 0172-reversible-harness-economy-setup.md:24 |
| 0173 | Native inline instruction installation | New (canon -> CLI); narrowed by 0174 | superseded | Only setup installation mechanics | 0173-native-harness-instruction-installation.md:27 |
| 0174 | Fixed native instruction targets | New (canon -> CLI) | superseded | Only setup targets | 0174-fixed-native-instruction-targets.md:21 |
| 0175 | One agent policy, one context gateway | New (canon -> CLI); narrowed by 0185 | superseded | `policy/agent.md`, its gateway routing and setup targets only | 0175-single-context-gateway.md:28 |
| 0176 | Delivery control contract | New (canon -> skills/CLI); narrowed by 0179 | narrowed | Ownership split, control strengths and fail-closed survive; D12 "installed agent policy" routing dies | 0176-native-delivery-control-contract.md:59 |
| 0177 | Policy provenance; canonical bytes | New (canon -> CLI) | superseded | Only the policy predecessor manifest and setup verification | 0177-agent-policy-provenance-and-upgrade-integrity.md:19 |
| 0178 | Restartable campaign goals | New (canon -> skills/CLI/MCP); narrowed by 0179 | narrowed | The campaign contract and native progress survive; D8 (C029–C031, contract 0.24.0) and the D10 CLI/MCP clause die | 0178-restartable-campaign-goals.md:47 |
| 0179 | Operation-scoped campaign preflight | New (canon -> skills) | none | D10 "CLI and MCP contracts do not change" is a negation and incidental | 0179-proportional-campaign-authority.md:50 |
| 0180 | Evidence-bounded execution | New (canon -> skills/CLI) | none | D5 "no CLI command or MCP tool" is a negation and incidental | 0180-evidence-bounded-execution.md:35 |
| 0181 | Evidence-settled decisions; panels | New (canon -> skills/CLI/MCP); narrowed by 0186 | narrowed | The settle/panel method survives; D9 (contract 0.25.0 `panel` type) dies | 0181-evidence-settled-decisions-and-bounded-panels.md:45 |
| 0183 | Single-file skills; role-routed models | New (canon -> skills); narrowed by 0186 | none | No CLI/MCP clause | 0183-single-file-skills-and-role-routed-models.md:21 |
| 0184 | Drill, native review, delete review packet | New (canon -> skills/CLI/MCP) | narrowed | Native independent review and drill survive; D4's CLI `--task`, contract 0.26.0 and RESERVED IDs die | 0184-two-doors-drill-native-review.md:25 |
| 0185 | Cursor and Antigravity setup targets | New (canon -> CLI) | superseded | Only `suspec setup` targets | 0185-cursor-and-antigravity-setup-targets.md:19 |
| 0186 | Artifact authors ship with canon | New (canon -> skills/CLI/MCP) | narrowed | D1–D3 and D5 survive; D4's contract 0.27.0 and the "family is canon, CLI, and MCP" narrowing note die | 0186-artifact-authors-ship-with-canon.md:43 |

Judgement calls (for each, the evidence was not decisive, and the tie-break rule chose `narrowed`):
- 0083: the `verify` block was a review-packet format, the review packet was deleted by 0184, and the block is absent from current artifact-formats.md. Only the spot-check and consistency-not-truth doctrine remains.
- 0116: current artifact-formats.md has no `active` spec status. The invariant's subject may already be obsolete for reasons outside ADR-0187.
- 0125: the method rule survives only as the AC-NNN digits format.
- 0165: D3 is the only surviving clause.

## Lists

SUPERSEDED: 0070, 0077, 0078, 0079, 0081, 0084, 0085, 0086, 0087, 0091, 0097, 0107, 0126, 0127, 0128, 0129, 0130, 0136, 0143, 0153, 0172, 0173, 0174, 0175, 0177, 0185
NARROWED: 0063, 0066, 0080, 0083, 0088, 0090, 0094, 0096, 0110, 0113, 0116, 0125, 0134, 0137, 0138, 0140, 0141, 0144, 0145, 0152, 0154, 0157, 0158, 0159, 0164, 0165, 0166, 0171, 0176, 0178, 0181, 0184, 0186
NONE: 0061, 0062, 0064, 0069, 0073, 0074, 0076, 0089, 0092, 0093, 0095, 0098, 0099, 0100, 0101, 0103, 0106, 0111, 0112, 0114, 0115, 0117, 0119, 0121, 0124, 0135, 0139, 0142, 0179, 0180, 0183
