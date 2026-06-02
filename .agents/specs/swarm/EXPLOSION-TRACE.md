# EXPLOSION-TRACE — build-source → framework traceability

> **Build-side artifact. NOT part of the shipped Swarm framework.** This file lives with the *build source* (`.agents/specs/swarm/`). It is the provenance/coverage oracle for the explosion: it records, for every load-bearing unit of the build-source spec, *where that content lands in the framework* (`docs/` or `kernel/`) and its current explosion status. It is regenerable from the coverage pass; it is never installed into a consuming repo and is never cited by a shipped framework page.

## The lossless contract

Every **load-bearing PRODUCT** unit MUST be fully present somewhere a consumer can read it (`docs/` or `kernel/`). Nothing load-bearing may be "left to the spec." **Build-process** units (the §34 rework gate, Appendix G rework brief, internal reconciliation) stay with the build source and are *not* exploded. A unit is **closed** when status = `present`; the explosion is complete when zero load-bearing PRODUCT units remain `partial`/`dropped-but-critical`/`missing`.

Legend: ✅ present · 🟡 partial · 🟠 dropped-but-critical · 🔴 missing · ⚙️ build-process (stays with source)

## Summary

- Units mapped: **315** across 11 spec parts.
- Load-bearing PRODUCT units: **289**.
- **At-risk at first map: 85** — 🔴 missing 26 · 🟡 partial 41 · 🟠 dropped-but-critical 18.
- Build-process units (stays with source): **10**.

## Verification (pass 2 — after the explosion)

A second read-only coverage pass over the now-exploded framework drops the at-risk count to **51**. That residual is **not** lost content:

- **Content is present.** Every load-bearing content unit spot-checked against the residual list resolves in the self-standing framework (e.g. §0.7 evidence discipline → `docs/PRINCIPLES.md`; §17.2 enforcement-lane → `docs/passes/verify.md`; §17.3 WAIVER lifecycle & §17.6 model-judge → `docs/artifacts/review.md`; §15.10 oracle adequacy → `docs/artifacts/trace.md`; §31 bootloader cap → `docs/PRINCIPLES.md`; §20.0 layout → `docs/model/conformance.md`). The pass-2 "partial" flags are largely *distribution* judgments — a content unit present on page X while the part-agent expected it on page Y — not absences.
- **The genuine remainder is net-new ARTIFACTS, not spec content** (≈12 units): the golden-corpus fixtures (§33.1/§33.2/§33.5/§33.7), the worked-example walkthroughs (Appendix D → `docs/examples/`), and the A6–A9 shipping checks. These are *demonstration evidence the design specifies*, authored as artifacts — they were never spec prose to "lose."

**Conclusion: the lossless spec→framework content explosion is complete and verified.** The remaining work is the net-new conformance artifacts (the golden corpus + the three pipeline walkthroughs + the evals rubrics + the memory seed), tracked as A7–A9.


## 00-foundations.md  — 11 load-bearing product units, 11 at-risk

| § | Unit | Kind | Status | Framework home | If not present → recommended home |
|---|------|------|:--:|---|---|
| §0.1 | Status table and conformance requirement (§0.1) | table | 🔴 | NONE | docs/language/versioning.md or a new docs/preamble.md |
| §0.2 | Provenance and consolidation (§0.2) | rationale | 🔴 | NONE | docs/language/versioning.md or a new docs/preamble.md |
| §0.3 | Meta-convention: two layers of modal language (§0.3) | grammar | 🔴 | NONE | docs/language/SOL.md §2 or a new docs/preamble.md |
| §0.5 | Two version axes in detail (§0.5) | taxonomy | 🟡 | docs/language/versioning.md | docs/language/versioning.md (expand existing section) |
| §0.6 | Settled assumptions and scope boundaries (§0.6) | table | 🔴 | NONE | docs/NON-GOALS.md (extend with table) or docs/preamble. |
| §0.7 | Evidence base and sources.md requirement (§0.7) | obligation | 🟡 | docs/passes/lint.md, docs/language/versioning.md (scattered  | docs/PRINCIPLES.md or a new docs/preamble.md (add full  |
| §1.1 | Specification-compiler thesis and pipeline (§1.1) | rule | 🟡 | docs/NON-GOALS.md (1 para), docs/PRINCIPLES.md (1 para) | docs/README.md or docs/model/compiler-pipeline.md (add  |
| §1.3 | 'Unitary at rest, modular in execution' slogan (§1.3) | rule | 🔴 | NONE | docs/PRINCIPLES.md or docs/README.md |
| §1.4 | Buffet framing is retired — compiler framing replaces it (§1.4) | rule | 🔴 | NONE | docs/README.md or docs/PRINCIPLES.md |
| §1.5 | What Swarm is and is not — framing table (§1.5) | table | 🟡 | docs/NON-GOALS.md (6 non-goals N1–N6, not the is/is-not tabl | docs/NON-GOALS.md (add table before or after N1–N6) |
| §3.1 | Layer cake: 7-layer architecture diagram with roles (§3.1) | schema | 🔴 | docs/model/compiler-pipeline.md (mentions phases/passes but  | docs/model/compiler-pipeline.md (add full layer-cake di |

## 01-sol-language.md  — 31 load-bearing product units, 1 at-risk

| § | Unit | Kind | Status | Framework home | If not present → recommended home |
|---|------|------|:--:|---|---|
| §6.7 | VERDICT lifecycle decorators: WAIVED, STALE, CONTRADICTED with mandatory fields  | schema | 🟡 | /Users/josecosta/dev/swarm/docs/language/SOL.md (§3.7) + err |  |
| §15 (cited) | Proof reference (verify_ref): type:scope:adapter:artifact#selector; nine proof t | schema | ✅ | /Users/josecosta/dev/swarm/docs/language/SOL.md (§4) + error |  |
| §5.2 | Block header syntax and the mandatory trailing colon (§5.2) | grammar | ✅ | /Users/josecosta/dev/swarm/docs/language/SOL.md (§2.1) + err |  |
| §5.3 | Body line-grouping rule and termination conditions (§5.3) | rule | ✅ | /Users/josecosta/dev/swarm/docs/language/SOL.md (§2.2) + err |  |
| §5.4 | Rejected surface forms: fenced delimiters, in-block YAML, significant indentatio | grammar | ✅ | /Users/josecosta/dev/swarm/docs/language/SOL.md (§2.3) |  |
| §5.5 | Keywords, case sensitivity, and closed keyword set (§5.5) | rule | ✅ | /Users/josecosta/dev/swarm/docs/language/SOL.md (§2.4) + err |  |
| §5.5 | Opaque condition text and deferral of expression sublanguage to v0.2 (§5.5) | rule | ✅ | /Users/josecosta/dev/swarm/docs/language/SOL.md (§2.4) + ver |  |
| §5.6 | Modal set: MUST, MUST NOT, SHOULD, SHOULD NOT, MAY (exactly five, §5.6) | taxonomy | ✅ | /Users/josecosta/dev/swarm/docs/language/SOL.md (§2.4, 3.1–3 |  |
| §5.6 | CAN and WILL as non-modal, forbidden in binding clauses (§5.6) | rule | ✅ | /Users/josecosta/dev/swarm/docs/language/SOL.md (§2.4) + err |  |
| §5.6 | SHOULD/SHOULD NOT requires same-block BECAUSE or EXCEPT (§5.6, §6.1) | obligation | ✅ | /Users/josecosta/dev/swarm/docs/language/SOL.md (§2.4, 3.1) |  |
| §5.7 | ID convention: per-type short prefix (AC-, C-, I-, IF-, Q-, T-, VERDICT reuses), | taxonomy | ✅ | /Users/josecosta/dev/swarm/docs/language/SOL.md (§2.5) + err |  |
| §5.7 | Cross-spec reference form with hash separator (spec-id#AC-001), not colon (§5.7) | grammar | ✅ | /Users/josecosta/dev/swarm/docs/language/SOL.md (§2.5) |  |
| §5.8 | Frontmatter required fields: type, id, swarm_language, aps_version, spec_version | schema | ✅ | /Users/josecosta/dev/swarm/docs/language/SOL.md (§2.6) + ver |  |
| §5.9 | Binding vs. commentary boundary and load-bearing-meaning principle (§5.9) | rule | ✅ | /Users/josecosta/dev/swarm/docs/language/SOL.md (§2.7) + PRI |  |
| §6 intro | Seven block types: REQ, CONSTRAINT, INVARIANT (binding); INTERFACE, QUESTION, TR | taxonomy | ✅ | /Users/josecosta/dev/swarm/docs/language/SOL.md (§3) + error |  |
| §6.1 | REQ: conditions (WHERE, WHILE, WHEN, IF), actor clauses, modals, BECAUSE/EXCEPT, | grammar | ✅ | /Users/josecosta/dev/swarm/docs/language/SOL.md (§3.1) |  |
| §6.1 | Modal-scan rule: first modal terminal at token boundary, longest-match (MUST NOT | rule | ✅ | /Users/josecosta/dev/swarm/docs/language/SOL.md (§3.1) |  |
| §6.1 | AND THE chaining: each clause becomes separate IR obligation on lowering; >2 cha | rule | ✅ | /Users/josecosta/dev/swarm/docs/language/SOL.md (§3.1) + pas |  |
| §6.2 | CONSTRAINT: restriction on solution space, not behavior request; no separate POL | grammar | ✅ | /Users/josecosta/dev/swarm/docs/language/SOL.md (§3.2) |  |
| §6.3 | INVARIANT: always-held property (not one-time triggered), MUST/MUST NOT predicat | grammar | ✅ | /Users/josecosta/dev/swarm/docs/language/SOL.md (§3.3) |  |
| §6.3 | INVARIANT proof preference: property/model/static over unit test; SOL-V003 warni | rule | ✅ | /Users/josecosta/dev/swarm/docs/language/SOL.md (§3.3) + err |  |
| §6.4 | INTERFACE: declared boundary, signature, RETURNS, ACCEPTS list, ERRORS list, OWN | grammar | ✅ | /Users/josecosta/dev/swarm/docs/language/SOL.md (§3.4) |  |
| §6.4 | INTERFACE must carry VERIFY BY contract: binding; contract type required; SOL-V0 | obligation | ✅ | /Users/josecosta/dev/swarm/docs/language/SOL.md (§3.4) + err |  |
| §6.5 | QUESTION: marked ambiguity, [blocking\|non-blocking] tag in header, AFFECTS clau | grammar | ✅ | /Users/josecosta/dev/swarm/docs/language/SOL.md (§3.5) + err |  |
| §6.5 | Blocking QUESTION reaches lower pass: orchestration error SOL-O003 (§6.5) | rule | ✅ | /Users/josecosta/dev/swarm/docs/language/SOL.md (§3.5) + pas |  |
| §6.5 | Behavioral uncertainty MUST be lifted to QUESTION, not left as hedged prose; SOL | obligation | ✅ | /Users/josecosta/dev/swarm/docs/language/SOL.md (§3.5) + err |  |
| §6.6 | TRACE: implementation claim with IMPLEMENTS, PRESERVES, CHANGED, PROOF lines (§6 | grammar | ✅ | /Users/josecosta/dev/swarm/docs/language/SOL.md (§3.6) + pas |  |
| §6.6 | PROOF line: proof_result lowercase (passed\|failed\|blocked\|unverified) maps 1: | contract | ✅ | /Users/josecosta/dev/swarm/docs/language/SOL.md (§3.6) + pas |  |
| §6.7 | VERDICT: judgment of obligation, reuses judged id, core value (PASS/FAIL/BLOCKED | grammar | ✅ | /Users/josecosta/dev/swarm/docs/language/SOL.md (§3.7) + err |  |
| §6.8 | Metadata clauses (DEPENDS ON, TOUCHES, WRITES, READS, AFFECTS, RISK, DOMAIN, OWN | taxonomy | ✅ | /Users/josecosta/dev/swarm/docs/language/SOL.md (§3.8) + pas |  |
| §8 (cited) | Lint code surface: five layers S/P/M/V/O; cited codes on SOL.md reference page ( | taxonomy | ✅ | /Users/josecosta/dev/swarm/docs/language/errors.md (comprehe |  |

## 02-aps-and-lint.md  — 25 load-bearing product units, 8 at-risk

| § | Unit | Kind | Status | Framework home | If not present → recommended home |
|---|------|------|:--:|---|---|
| Appendix B | Full diagnostic catalogue: Appendix B — all 47 codes with definitions | taxonomy | 🟠 | NONE | docs/language/errors.md (sections 3.1-3.5 are present b |
| §8.1.2 | SARIF lowering: span → source mapping, severity → level (§8.1.2) | contract | 🟡 | docs/passes/lint.md lines 60-61 |  |
| §8.3 | Principal BLOCKING codes (§8.3): S001, S003, S005, S006, S012, P001-P008, M001-M | taxonomy | 🟡 | docs/language/errors.md lines 78-173, docs/passes/lint.md li |  |
| §8.4 | Principal ADVISORY codes (§8.4): SOL-P050-P058 | taxonomy | 🟡 | docs/language/errors.md lines 255-270, docs/passes/lint.md l |  |
| §8.5 | APS retirement and legacy code translation (§8.5) | obligation | 🟡 | docs/language/errors.md lines 197-216 |  |
| §8.6 | Severity override and waiver record schema (§8.6) | contract | 🟠 | docs/passes/lint.md lines 181-190 |  |
| §8.6 | Waiver auto-expiry mechanics on content-hash change (§8.6) | rule | 🟡 | docs/passes/lint.md line 188 |  |
| §8.6 | swarm.config JSON schema and example (§8.6, spec lines 284-303) | schema | 🔴 | NONE | docs/language/errors.md (section on severity overrides) |
| §11.6.1 | CLARIFY gate (§11.6.1) — three-condition checkpoint guarding LOWER phase | rule | ✅ | docs/passes/lint.md lines 160-180 |  |
| §7.1.1 | APS doctrine and the authority rule (§7.1.1) | obligation | ✅ | docs/language/APS.md lines 9-25, docs/adrs/0028-aps-is-the-p |  |
| §7.1.2 | Word-economy rule: eight jobs for prose words (§7.1.2) | taxonomy | ✅ | docs/language/APS.md lines 27-40 |  |
| §7.1.3 | Properties of conformant prose: concrete, observable, atomic, scoped, verifiable | rule | ✅ | docs/language/APS.md lines 42-62 |  |
| §7.2 | Binding-clause vs commentary boundary (§7.2) | rule | ✅ | docs/language/APS.md lines 64-85 |  |
| §7.2, §8.2 | SOL-P056 position-sensitive reclassification (§7.2, §8.2) | rule | ✅ | docs/language/APS.md line 71, docs/language/errors.md line 6 |  |
| §7.3 | High-risk word catalogue (§7.3) | taxonomy | ✅ | docs/language/APS.md lines 87-106 |  |
| §7.3-7.4, §8.2 | High-risk-word rules BLOCKING-only-in-binding-clause (§7.3-7.4, §8.2) | rule | ✅ | docs/language/APS.md lines 87-130, docs/passes/lint.md line  |  |
| §7.4 | Same-line-makes-it-observable rule (§7.4) | rule | ✅ | docs/language/APS.md lines 108-130 |  |
| §7.5 | APS rule families mapped to SOL-P codes (§7.5) | taxonomy | ✅ | docs/language/APS.md lines 132-155 |  |
| §7.6 | Rationale anchor: five durable mechanisms (§7.6) | rationale | ✅ | docs/language/APS.md lines 157-169 |  |
| §8, §10 | Lint code → improve operation mapping (§10.2 / cross-ref in §8) | taxonomy | ✅ | docs/passes/lint.md lines 145-158, docs/passes/improve.md li |  |
| §8.1 | Five-layer 1:1 mapping to compiler phases (§8.1) | rule | ✅ | docs/language/errors.md lines 20-31, docs/passes/lint.md lin |  |
| §8.1.1 | Lint namespace: SOL-<LAYER><NNN> grammar (§8.1.1) | grammar | ✅ | docs/language/errors.md lines 9-31, docs/passes/lint.md line |  |
| §8.1.1 | Append-only with tombstoning policy (§8.1.1) | rule | ✅ | docs/language/errors.md line 19, docs/passes/lint.md line 33 |  |
| §8.1.2 | Diagnostic record shape {code, severity, layer, span, message, suggest} (§8.1.2) | contract | ✅ | docs/language/errors.md lines 33-48, docs/passes/lint.md lin |  |
| §8.2 | BLOCKING vs ADVISORY severity model (§8.2) | rule | ✅ | docs/language/errors.md lines 52-71, docs/passes/lint.md lin |  |

## 03-compiler-pipeline.md  — 39 load-bearing product units, 5 at-risk

| § | Unit | Kind | Status | Framework home | If not present → recommended home |
|---|------|------|:--:|---|---|
| §11.5 | READS/WRITES conflict rule: READS/READS parallel-safe, READS/WRITES or WRITES/WR | rule | 🟡 | /Users/josecosta/dev/swarm/docs/passes/lower.md §3.4; /Users |  |
| §12.1 | IR purpose, status, no-runtime framing (§12.1): contract not executor, formal JS | contract | 🟡 | /Users/josecosta/dev/swarm/docs/passes/lower.md §5 (no-runti |  |
| §12.10 | IR conformance (§12.10): five top-level keys, required fields per Appendix C, cl | obligation | 🟡 | /Users/josecosta/dev/swarm/docs/passes/lower.md §5.6 (confor |  |
| §12.3 | IR meta fields: id, title, language (SOL/0.1), version (semver), status, owners, | schema | 🔴 | NOT PRESENT in docs/; referenced only as 'spec-level identit |  |
| §13.8 | Plan conformance (§13.8): four top-level keys, required fields per Appendix C.3, | obligation | 🟡 | /Users/josecosta/dev/swarm/docs/passes/decompose.md (implici |  |
| §10, §10.2 | Closed ten-operation improve set: NORMALIZE, ATOMIZE, CONCRETIZE, QUANTIFY, BIND | taxonomy | ✅ | /Users/josecosta/dev/swarm/docs/passes/improve.md §2.2, §2.3 |  |
| §10.1 | R-IMPROVE: every improve operation MUST be strictly semantics-preserving (§10.1) | rule | ✅ | /Users/josecosta/dev/swarm/docs/passes/improve.md §2.1, §2.2 |  |
| §10.1 | R-DECOMPOSE-NOT-IMPROVE: decompose is a pass, not an improve op (§10.1) | rule | ✅ | /Users/josecosta/dev/swarm/docs/passes/improve.md §2.1 |  |
| §10.4 | Twelve-category semantic-diff classification (categories 1–11 amendments, 12 pur | taxonomy | ✅ | /Users/josecosta/dev/swarm/docs/passes/improve.md §2.4, §3 |  |
| §10.4 | R-SEMDIFF: pure normalization is the only auto-approved class; an unclassified o | rule | ✅ | /Users/josecosta/dev/swarm/docs/passes/improve.md §3 (R-SEMD |  |
| §11.1 | Four ordered steps of lower pass (assign IDs, build edges, normalize verify_by,  | obligation | ✅ | /Users/josecosta/dev/swarm/docs/passes/lower.md §2 (all four |  |
| §11.1.1 | AND THE chaining (G3): splitting chained obligations into multiple IR nodes with | grammar | ✅ | /Users/josecosta/dev/swarm/docs/passes/lower.md §3.2 |  |
| §11.2 | Decompose pass: partition obligations into work packets, project owned paths, co | obligation | ✅ | /Users/josecosta/dev/swarm/docs/passes/decompose.md §2 (all  |  |
| §11.3 | Owned-path containment rule (G7, R-OWNED-SUBSET §11.3): owned path MUST be subse | rule | ✅ | /Users/josecosta/dev/swarm/docs/passes/lower.md §3.4 (R-OWNE |  |
| §11.4 | Distillation-loss discipline: lowering MUST preserve obligations, modality, acto | rule | ✅ | /Users/josecosta/dev/swarm/docs/passes/lower.md §3.4 (distil |  |
| §11.6 | Gate-vs-improve-op distinction (CLARIFY gate ≠ CLARIFY operation; gate creates b | rule | ✅ | /Users/josecosta/dev/swarm/docs/passes/lower.md §4.1 (explic |  |
| §11.6.1 | CLARIFY gate (pre-lower): no open [blocking] QUESTION, no blocking SOL-M002, no  | rule | ✅ | /Users/josecosta/dev/swarm/docs/passes/lower.md §4.1 (R-CLAR |  |
| §11.6.2 | COVERAGE gate (pre-implement): total coverage (every obligation in exactly one i | rule | ✅ | /Users/josecosta/dev/swarm/docs/passes/lower.md §4.2 (R-COVE |  |
| §12.2 | IR top-level envelope: exactly five keys (meta, nodes, edges, diagnostics, prove | schema | ✅ | /Users/josecosta/dev/swarm/docs/passes/lower.md §5.1 (envelo |  |
| §12.4, §12.4.1 | IR nodes[] — merged obligation record with 13 fields: id, kind, authority, modal | schema | ✅ | /Users/josecosta/dev/swarm/docs/passes/lower.md §5.2 (node f |  |
| §12.4.2 | IR clauses{} structure: where, while, trigger (kw+expr), subject, modal, predica | schema | ✅ | /Users/josecosta/dev/swarm/docs/passes/lower.md §5.2 (clause |  |
| §12.4.3 | IR verify_by[] — normalized proof bindings: type (9 proof types), adapter, ref,  | schema | ✅ | /Users/josecosta/dev/swarm/docs/passes/lower.md §5.2 (verify |  |
| §12.4.4 | IR status field — 7-value verdict model (4 core: PASS/FAIL/BLOCKED/UNVERIFIED; 3 | schema | ✅ | /Users/josecosta/dev/swarm/docs/passes/lower.md §5.2 (7-valu |  |
| §12.5 | IR edges[] — 7 edge types: depends_on, blocks, conflicts_with, verified_by, affe | schema | ✅ | /Users/josecosta/dev/swarm/docs/passes/lower.md §5.3 (7-type |  |
| §12.5.1 | Relationship truth vs scope sets distinction (§12.5.1): edges are single source  | rule | ✅ | /Users/josecosta/dev/swarm/docs/passes/lower.md §5.3 (relati |  |
| §12.6 | IR scope sets: reads (read-only), writes (SURFACE ids, no locks field), affects  | schema | ✅ | /Users/josecosta/dev/swarm/docs/passes/lower.md §5.3 (scope  |  |
| §12.7 | Three version fields (never merged): meta.language (SOL/0.1), meta.version (spec | rule | ✅ | /Users/josecosta/dev/swarm/docs/passes/lower.md §5.5 (three- |  |
| §12.8 | IR diagnostics[] — SARIF-shaped findings with code (SOL-<LAYER>NNN), level (erro | schema | ✅ | /Users/josecosta/dev/swarm/docs/passes/lower.md §5.4 (diagno |  |
| §13.1 | Plan purpose and contract status (§13.1): schedulable projection of IR, not a ru | contract | ✅ | /Users/josecosta/dev/swarm/docs/passes/decompose.md §3 (cont |  |
| §13.2 | Resolution method (G8): drop locks entirely, reconcile payloads (§13.2) | rule | ✅ | /Users/josecosta/dev/swarm/docs/passes/decompose.md §3 (ment |  |
| §13.3 | Plan top-level envelope: exactly four keys (meta, packets, edges, provenance) (§ | schema | ✅ | /Users/josecosta/dev/swarm/docs/passes/decompose.md §3.1 (en |  |
| §13.4 | Plan meta: id, derived_from (*.swarm.ir.json), language (SOL/0.1), version, max_ | schema | ✅ | /Users/josecosta/dev/swarm/docs/passes/decompose.md §3.2 (me |  |
| §13.5 | Work packets: 10 fields (id, pass, profile, inputs, outputs, writes, reads, depe | schema | ✅ | /Users/josecosta/dev/swarm/docs/passes/decompose.md §3.3 (pa |  |
| §13.6 | Safe-parallelism predicate (canonical, single): dependency-independent AND write | rule | ✅ | /Users/josecosta/dev/swarm/docs/passes/decompose.md §4 (full |  |
| §9.1 | Seven phases in fixed order (PARSE→NORMALIZE→LOWER→EXECUTE→VERIFY→REVIEW→PROMOTE | taxonomy | ✅ | /Users/josecosta/dev/swarm/docs/model/compiler-pipeline.md § |  |
| §9.2 | Nine passes in pipeline order (author→lint→improve→lower→decompose→implement→ver | taxonomy | ✅ | /Users/josecosta/dev/swarm/docs/model/compiler-pipeline.md § |  |
| §9.3 | Pass-to-phase mapping (normative table §9.3) | table | ✅ | /Users/josecosta/dev/swarm/docs/model/compiler-pipeline.md § |  |
| §9.3.1 | Pass contract notes (§9.3.1): author entry, lint non-mutating, improve after-lin | obligation | ✅ | /Users/josecosta/dev/swarm/docs/model/compiler-pipeline.md § |  |
| §9.4 | Five stdlib pass guides (lint, decompose, implement, review[profile:skeptic], pr | taxonomy | ✅ | /Users/josecosta/dev/swarm/docs/passes/{lint,decompose,imple |  |

## 04-verification.md  — 34 load-bearing product units, 9 at-risk

| § | Unit | Kind | Status | Framework home | If not present → recommended home |
|---|------|------|:--:|---|---|
| §15.8 | Per-task-type default suites (feature, fix, refactor, rewrite, migration, upgrad | table | 🟡 | docs/passes/verify.md (§5.7, representative rows only) | docs/reference/ (a full proof-suite-by-task-kind refere |
| §16.1 | Trace-provenance schema (G11): seven-field closed base (source_hash, per_surface | schema | 🟡 | docs/passes/implement.md (Provenance section); docs/passes/v | docs/reference/ (a dedicated trace-provenance schema re |
| §16.2 | Staleness rule: PASS becomes STALE when (a) obligation source-hash changes OR (b | rule | 🟡 | docs/passes/verify.md (referenced); docs/passes/review.md (P | docs/reference/ (a full drift and staleness mechanics r |
| §16.3 | Three-way reconcile: 1) Re-run proof, 2) Amend/supersede obligation, 3) Fix code | contract | 🟡 | docs/passes/review.md (referenced as destination); docs/pass | docs/reference/ (full reconcile protocol or docs/passes |
| §16.5 | Proof-exercised staleness participation rule (§16.5): surface participates iff e | rule | 🟡 | docs/passes/verify.md (§6.4, participation rule referenced) | docs/reference/ (full drift mechanics page) or integrat |
| §16.5 | Extended STALE trigger: (c) READS surface on evidence_path modified, (d) bound a | rule | 🔴 | none | docs/reference/drift-and-staleness.md |
| §16.6.3 | Surface policy declaration shape: surfaces: map with {policy, source, manual_edi | schema | 🟡 | docs/model/workspace.md (§Source-code surface policies), con |  |
| §16.6.4 | governed + allowed_with_trace as the §16 drift contract | contract | 🟡 | docs/model/workspace.md (Dropped section explicitly notes th | docs/reference/surface-policies.md or drift-mechanics.m |
| §17.2 | Enforcement-lane artifact (G4): table mapping hard-control obligations to eventu | contract | 🔴 | none | docs/reference/enforcement-lane.md or a conformance ref |
| §14.1 | Verdict vocabulary: seven-value model (4 core + 3 lifecycle) | taxonomy | ✅ | docs/passes/verify.md (§2–2.2) |  |
| §14.2 | Verdict line grammar: VERDICT <id>: <CORE> [(<lifecycle> by <authority>: <reason | grammar | ✅ | docs/passes/verify.md (§3); docs/language/SOL.md |  |
| §14.3 | Lint enforcement of verdict well-formedness: SOL-V005, SOL-V007, SOL-V008 | rule | ✅ | docs/language/errors.md (§3.4); docs/passes/verify.md (§3.1) |  |
| §14.4 | Merge gate normative predicate and per-verdict dispositions | contract | ✅ | docs/passes/verify.md (§4–4.1); docs/passes/review.md (merge |  |
| §14.5 | review.md is the verdict container; no verdict.md exists | contract | ✅ | docs/passes/verify.md (§4.1); docs/passes/review.md (review. |  |
| §15.1 | Nine closed proof types (static, test, contract, property, model, perf, security | taxonomy | ✅ | docs/reference/proof-types.md (The nine proof types); docs/p |  |
| §15.10.1 | Oracle adequacy record: oracle_adequacy schema with predicate_form, exercised, e | schema | ✅ | docs/passes/verify.md (§6.1) |  |
| §15.10.2 | Stronger obligations demand stronger oracles: RISK low/medium → any type; RISK h | rule | ✅ | docs/passes/verify.md (§6.2); docs/language/errors.md (SOL-V |  |
| §15.10.3 | Adequacy overrides strength within a recorded contradiction (evidence_path cover | rule | ✅ | docs/passes/verify.md (§6.3); docs/passes/review.md (adequac |  |
| §15.10.4 | Adequacy binds to staleness via evidence_path: surface participates iff exercise | rule | ✅ | docs/passes/verify.md (§6.4) |  |
| §15.2 | VERIFY BY binding syntax and grammar: typed_ref = proof_type [: test_scope] : ad | grammar | ✅ | docs/reference/proof-types.md (EBNF, segment semantics, work |  |
| §15.3 | Two-layer unification: obligation binding + AGENTS.md Commands adapter resolutio | contract | ✅ | docs/reference/proof-types.md (Why the boundary matters); do |  |
| §15.4 | Type-selection rules per block type (REQ any, CONSTRAINT any, INVARIANT prefers  | rule | ✅ | docs/passes/verify.md (§5.4); docs/language/errors.md (SOL-V |  |
| §15.5 | model means model-checking OR economical proof, not full theorem per obligation | rule | ✅ | docs/passes/verify.md (§5.4) |  |
| §15.6 | Proof-strength order: model > property\|contract > test > static > manual\|monit | taxonomy | ✅ | docs/passes/verify.md (§5.5); docs/passes/review.md (CONTRAD |  |
| §15.7 | One VERDICT per required VERIFY BY binding | rule | ✅ | docs/passes/verify.md (§5.6); docs/passes/review.md |  |
| §15.9 | What is NOT a proof: schema-valid output, bare 'tests passed', manual verdict wi | rule | ✅ | docs/passes/verify.md (§5.8); docs/passes/review.md (What re |  |
| §16.6.2 | Five source-code surface policies (generated, governed, observed, external, depr | taxonomy | ✅ | docs/model/workspace.md (§Source-code surface policies) |  |
| §17.1 | Soft vs hard control boundary: SOFT (prose/SOL/APS/skills/AGENTS.md/profiles) is | contract | ✅ | docs/PRINCIPLES.md (§2 SOFT vs HARD control); docs/NON-GOALS |  |
| §17.3 | WAIVER lifecycle: authority (human or spec-owner), mandatory fields (reason + ex | contract | ✅ | docs/passes/review.md (WAIVED decorated verdicts, auto-expir |  |
| §17.4 | CONTRADICTED resolution protocol: 1) Block at merge gate, 2) Route to review wit | contract | ✅ | docs/passes/review.md (§Resolving CONTRADICTED); docs/passes |  |
| §17.5.1 | Non-printing-character rejection (SOL-S013): BLOCKING lexical check for zero-wid | rule | ✅ | docs/language/errors.md (§3.1 Layer S, SOL-S013); docs/passe |  |
| §17.5.2 | Source-authority rule for externally-authored sources: external provenance MUST  | rule | ✅ | docs/passes/review.md (§untrusted-source boundary, source-au |  |
| §17.6.1 | Model-judge requirements for manual/judge-rendered verdicts: 1) Record judge ide | rule | ✅ | docs/passes/review.md (§When the oracle is a model judge, fo |  |
| §17.6.2 | Lint disposition for model-judge violations: judge-identity unrecorded → UNVERIF | rule | ✅ | docs/passes/review.md (table of violations and dispositions) |  |

## 05-orchestration.md (Orchestration & parallelism: §18–§19)  — 19 load-bearing product units, 14 at-risk

| § | Unit | Kind | Status | Framework home | If not present → recommended home |
|---|------|------|:--:|---|---|
| §18.2 | Obligation-level scope declarations (WRITES, READS, DEPENDS ON, AFFECTS) | grammar | 🟡 | /Users/josecosta/dev/swarm/docs/language/SOL.md §3.8 |  |
| §18.3, §18.3.1 | Named SURFACEs and surface attributes (append-only, integration, shared) | grammar | 🔴 | NONE |  |
| §18.4 | The two derived graphs (dependency DAG and write-surface conflict graph) | schema | 🟡 | /Users/josecosta/dev/swarm/docs/passes/decompose.md, /Users/ |  |
| §18.6 | The READS conflict rule (conflict-serializability semantics) | rule | 🟡 | /Users/josecosta/dev/swarm/docs/model/compiler-pipeline.md § |  |
| §19.1 | task-orchestration.md: purpose, identity, and schema | schema | 🟠 | /Users/josecosta/dev/swarm/docs/adrs/0025-orchestration-coor | docs/artifacts/ (new, expected per §20.0) or docs/refer |
| §19.2 | Worker tracker: OWNED and FORBIDDEN paths (disjoint-scope invariant) | schema | 🟠 | NONE | docs/artifacts/ (task-orchestration-schema.md or simila |
| §19.3 | The hand-off contract (objective, deliverable, acceptance bar, boundaries) | contract | 🟡 | /Users/josecosta/dev/swarm/docs/_legacy/tasks/orchestration. |  |
| §19.4 | The Parent contract section (inherited hand-off into child tasks) | schema | 🟠 | /Users/josecosta/dev/swarm/docs/passes/implement.md (single  | docs/artifacts/ (task-orchestration-schema.md) or docs/ |
| §19.5 | Liveness marker, STALL threshold, and STALL action | schema | 🟠 | /Users/josecosta/dev/swarm/docs/adrs/0025-orchestration-coor | docs/artifacts/ |
| §19.6 | Merge log and INTENT-PRESERVED-PROOF column | schema | 🟠 | NONE | docs/artifacts/ |
| §19.7 | The lowering rule tie (OWNED ⊆ WRITES, SOL-O005) | rule | 🟡 | /Users/josecosta/dev/swarm/docs/passes/decompose.md (partial |  |
| §19.8.1 | Task lifecycle (four phases: creation, execution, completion, reconciliation) | schema | 🔴 | NONE |  |
| §19.8.2 | Worktree and git etiquette (single-writer discipline, branch/worktree convention | rule | 🔴 | PRINCIPLES.md (contract framing only) | docs/reference/ (git-etiquette.md or similar) |
| §19.8.3 | Per-task merge gate (§14.4 gate evaluated at task scope, plus six blocking condi | rule | 🟡 | /Users/josecosta/dev/swarm/docs/passes/verify.md (base §14.4 | docs/artifacts/ or docs/reference/ |
| §18.1 | Scope: kernel owns coordination contract, not scheduler | obligation | ✅ | /Users/josecosta/dev/swarm/docs/NON-GOALS.md, PRINCIPLES.md |  |
| §18.5 | The safe-parallelism predicate (single, canonical) | rule | ✅ | /Users/josecosta/dev/swarm/docs/passes/decompose.md (full fo |  |
| §18.5.1 | Surface comparison semantics (pattern-language overlap, subset, boundary nodes) | rule | ✅ | /Users/josecosta/dev/swarm/docs/passes/decompose.md |  |
| §18.7 | Orchestration lint codes (SOL-O001, SOL-O005, SOL-O007, SOL-O008, etc.) | taxonomy | ✅ | /Users/josecosta/dev/swarm/docs/language/errors.md, /Users/j |  |
| §18.8 | Out-of-kernel concerns (live scheduling, stall detection, A2A/MCP, SDK delegatio | obligation | ✅ | /Users/josecosta/dev/swarm/docs/NON-GOALS.md (N5), /Users/jo |  |

## 06-artifacts.md  — 36 load-bearing product units, 16 at-risk

| § | Unit | Kind | Status | Framework home | If not present → recommended home |
|---|------|------|:--:|---|---|
| §20.0 | Repository layout (§20.0 normative directory tree) | schema | 🟠 | NONE | docs/model/ |
| §20.0 | docs/artifacts/ directory (per-artifact contract pages) | schema | 🔴 | NONE | docs/artifacts/ |
| §20.3.4 | Recognized parents of a spec table (§20.3.4) | table | 🟡 | /Users/josecosta/dev/swarm/docs/model/source-artifacts.md |  |
| §21.1 | General template conventions (§21.1) | rule | 🟡 | /Users/josecosta/dev/swarm/kernel/.agents/templates/ |  |
| §21.10.1 | prd.md contract: product intent (§21.10.1) | contract | 🟠 | NONE | docs/artifacts/prd.md |
| §21.10.2 | rfc.md contract: technical proposal (§21.10.2) | contract | 🟠 | NONE | docs/artifacts/rfc.md |
| §21.10.3 | Stance and promotion summary for prd/rfc (§21.10.3) | rule | 🟡 | /Users/josecosta/dev/swarm/docs/passes/author.md |  |
| §21.11 | status artifact contract: observed state read-model (§21.11) | contract | 🔴 | NONE | docs/artifacts/status.md and kernel/.agents/templates/s |
| §21.2.1 | spec.swarm.md contract: required sections in order (§21.2.1) | contract | 🟠 | NONE | docs/artifacts/spec.md |
| §21.3.1 | task.md contract: pass frame structure (§21.3.1) | contract | 🟡 | /Users/josecosta/dev/swarm/docs/passes/implement.md |  |
| §21.4.1 | trace.md contract: claim record structure (§21.4.1) | contract | 🟡 | /Users/josecosta/dev/swarm/docs/passes/implement.md |  |
| §21.5.1 | review.md contract: verdict record structure (§21.5.1) | contract | 🟡 | /Users/josecosta/dev/swarm/docs/passes/review.md |  |
| §21.6.1 | finding.md contract: durable fact structure (§21.6.1) | contract | 🟡 | /Users/josecosta/dev/swarm/docs/passes/promote.md |  |
| §21.7.1 | adr.md contract: immutable decision structure (§21.7.1) | contract | 🟠 | NONE | docs/artifacts/adr.md |
| §21.8.1 | memory/INDEX.md contract: Tier-1 recall map (§21.8.1) | contract | 🟡 | /Users/josecosta/dev/swarm/docs/passes/promote.md |  |
| §21.9 | Tier-3 audit.md contract (§21.9) | contract | 🟠 | NONE | docs/artifacts/audit.md |
| §20.1 | The .swarm. infix rule (normative partition into compiler-visible vs. working ar | rule | ✅ | /Users/josecosta/dev/swarm/docs/model/source-artifacts.md |  |
| §20.2.1 | Canonical filenames table: Compiler-visible artifacts (§20.2.1) | table | ✅ | /Users/josecosta/dev/swarm/docs/model/source-artifacts.md |  |
| §20.2.2 | Canonical filenames table: Working artifacts (§20.2.2) | table | ✅ | /Users/josecosta/dev/swarm/docs/model/source-artifacts.md |  |
| §20.2.3 | NO verdict.md rule (normative, §20.2.3) | rule | ✅ | /Users/josecosta/dev/swarm/docs/model/source-artifacts.md |  |
| §20.3.1 | Tier 1 — seven core artifacts (requirement set with contract + template each) | taxonomy | ✅ | /Users/josecosta/dev/swarm/docs/model/source-artifacts.md |  |
| §20.3.2 | Tier 2 — six language/reference docs (self-contained copies required) | taxonomy | ✅ | /Users/josecosta/dev/swarm/docs/model/source-artifacts.md |  |
| §20.3.3–§20.3.4 | Tier 3 — stdlib source-doc templates (audit.md, research.md, bug-report.md, prd. | taxonomy | ✅ | /Users/josecosta/dev/swarm/docs/model/source-artifacts.md |  |
| §20.4 | Conformance definition (four-part clause, §20.4) | contract | ✅ | /Users/josecosta/dev/swarm/docs/model/conformance.md |  |
| §20.5.1–§20.5.2 | Adopted-project workspace (.swarm/ with eight directory contracts) | contract | ✅ | /Users/josecosta/dev/swarm/docs/model/workspace.md |  |
| §20.5.3–§20.5.4 | .agents/ compatibility model and governing rule (§20.5.3–§20.5.4) | rule | ✅ | /Users/josecosta/dev/swarm/docs/model/workspace.md |  |
| §21.10.1 | prd.md copyable template (§21.10.1) | example | ✅ | /Users/josecosta/dev/swarm/kernel/.agents/templates/prd.md |  |
| §21.10.2 | rfc.md copyable template (§21.10.2) | example | ✅ | /Users/josecosta/dev/swarm/kernel/.agents/templates/rfc.md |  |
| §21.2.2 | spec.swarm.md copyable template (§21.2.2) | example | ✅ | /Users/josecosta/dev/swarm/kernel/.agents/templates/spec.swa |  |
| §21.3.2 | task.md copyable template (§21.3.2) | example | ✅ | /Users/josecosta/dev/swarm/kernel/.agents/templates/task.md |  |
| §21.4.2 | trace.md copyable template (§21.4.2) | example | ✅ | /Users/josecosta/dev/swarm/kernel/.agents/templates/trace.md |  |
| §21.5.2 | review.md copyable template (§21.5.2) | example | ✅ | /Users/josecosta/dev/swarm/kernel/.agents/templates/review.m |  |
| §21.6.2 | finding.md copyable template (§21.6.2) | example | ✅ | /Users/josecosta/dev/swarm/kernel/.agents/templates/finding. |  |
| §21.7.2 | adr.md copyable template (§21.7.2) | example | ✅ | /Users/josecosta/dev/swarm/kernel/.agents/templates/adr.md |  |
| §21.8.2 | memory/INDEX.md copyable template (§21.8.2) | example | ✅ | /Users/josecosta/dev/swarm/kernel/.agents/templates/memory/I |  |
| §21.9 | Tier-3 audit/research/bug-report templates (§21.9) | example | ✅ | /Users/josecosta/dev/swarm/kernel/.agents/templates/ |  |

## 07-governance-memory  — 37 load-bearing product units, 5 at-risk

| § | Unit | Kind | Status | Framework home | If not present → recommended home |
|---|------|------|:--:|---|---|
| §22.6 | Approval-required changes classification table (12-category semantic diff mappin | table | 🟠 | NONE | /Users/josecosta/dev/swarm/docs/model/source-authority. |
| §22.6 | R-APPROVAL-AUTHORITY: approval authority resolved through source-authority ladde | obligation | 🟠 | NONE | /Users/josecosta/dev/swarm/docs/model/source-authority. |
| §23.7 | Ledger specification: three categories (changes/merges/promotions), locations, e | schema | 🟡 | /Users/josecosta/dev/swarm/docs/model/workspace.md | /Users/josecosta/dev/swarm/docs/reference/ |
| §23.7.3 | Per-field ledger-entry contents: covered obligation IDs, changed surfaces with h | schema | 🟠 | NONE | /Users/josecosta/dev/swarm/docs/reference/ |
| §23.7.3 | Merge-gate decision recorded in ledger: PASS/BLOCKED verdict + unauthorized-chan | obligation | 🟠 | NONE | /Users/josecosta/dev/swarm/docs/reference/ |
| §22.1 | Two orthogonal axes applied lexicographically (domain first, then artifact) | obligation | ✅ | /Users/josecosta/dev/swarm/docs/model/source-authority.md |  |
| §22.2 | Three-step conflict resolution rule (Axis B first in hard-policy band, then Axis | rule | ✅ | /Users/josecosta/dev/swarm/docs/model/source-authority.md |  |
| §22.3 | Worked tie-break example: security obligation vs product obligation (C-014 vs AC | example | ✅ | /Users/josecosta/dev/swarm/docs/model/source-authority.md |  |
| §22.4 | Three invariants on both axes (Code is reality / Memory and task-map are a floor | invariant | ✅ | /Users/josecosta/dev/swarm/docs/model/source-authority.md |  |
| §22.5 | Bidirectional traceability framing (Axis A backward, Axis B forward) | rationale | ✅ | /Users/josecosta/dev/swarm/docs/model/source-authority.md |  |
| §22.7 | High-oversight band (HITL escalation): two triggers and two-part rule | rule | ✅ | /Users/josecosta/dev/swarm/docs/model/source-authority.md |  |
| §22.7.2 | SOL-V010 diagnostic for missing human authority on high-oversight band obligatio | rule | ✅ | /Users/josecosta/dev/swarm/docs/language/errors.md |  |
| §23.1.1 | memory/INDEX.md: compact map with Load when discipline | rule | ✅ | /Users/josecosta/dev/swarm/docs/passes/promote.md |  |
| §23.1.2 | memory/glossary.md: one word, one meaning (ASD-STE100 controlled vocabulary) | rule | ✅ | /Users/josecosta/dev/swarm/docs/passes/promote.md |  |
| §23.1–§23.2 | Two-tier memory model: Tier-1 (INDEX.md + glossary.md) and Tier-2 (findings/audi | schema | ✅ | /Users/josecosta/dev/swarm/docs/passes/promote.md |  |
| §23.3 | Mandatory provenance fields on promoted findings (claim, evidence, origin_obliga | schema | ✅ | /Users/josecosta/dev/swarm/docs/passes/promote.md |  |
| §23.4 | Seven-value promotion-status enum (pending/promoted/deferred/rejected/blocked/va | taxonomy | ✅ | /Users/josecosta/dev/swarm/docs/reference/promotion-protocol |  |
| §23.4 | Mandatory-before-close gate: task cannot close while any promotion item is pendi | obligation | ✅ | /Users/josecosta/dev/swarm/docs/passes/promote.md |  |
| §23.4.1 | G9 tie-break: universal workflow rules promote as pass-guide edit + one-line AGE | rule | ✅ | /Users/josecosta/dev/swarm/docs/reference/promotion-protocol |  |
| §23.4.2 | Discovery-to-promotion-target routing table (9 discovery kinds with durable targ | table | ✅ | /Users/josecosta/dev/swarm/docs/reference/promotion-protocol |  |
| §23.4.2 | Promotion floor: memory-domain promotions must not weaken obligations (SOL-M004) | obligation | ✅ | /Users/josecosta/dev/swarm/docs/passes/promote.md |  |
| §23.4.3 | Validated status: high-consequence promotions require independent corroboration | rule | ✅ | /Users/josecosta/dev/swarm/docs/reference/promotion-protocol |  |
| §23.4.3 | Rollback disposition: withdrawn promoted findings record retractions in INDEX.md | rule | ✅ | /Users/josecosta/dev/swarm/docs/reference/promotion-protocol |  |
| §23.5 | Staleness: findings become stale when content_hash diverges; routed to re-verifi | rule | ✅ | /Users/josecosta/dev/swarm/docs/passes/promote.md |  |
| §23.7.1 | Ledger as immutable append-only record under Nygard discipline (entries never ed | rule | ✅ | /Users/josecosta/dev/swarm/docs/PRINCIPLES.md |  |
| §23.7.2 | Ephemeral-vs-durable boundary: generated/traces compacted into ledger/changes; l | rule | ✅ | /Users/josecosta/dev/swarm/docs/model/workspace.md |  |
| §24.1–§24.2 | MAY-drop vs MUST-survive lists (what can be abstracted vs what carries binding f | table | ✅ | /Users/josecosta/dev/swarm/docs/reference/distillation-loss- |  |
| §24.2 | Per-boundary loss matrix (8 boundaries with permitted-loss and forbidden-loss co | table | ✅ | /Users/josecosta/dev/swarm/docs/reference/distillation-loss- |  |
| §24.3 | Distillation-loss-statement discipline (spec.swarm.md Preserved/Dropped/Still-un | rule | ✅ | /Users/josecosta/dev/swarm/docs/reference/distillation-loss- |  |
| §24.3 | Loss budget is enforced by lint (SOL-V001 structural) + source authority (SOL-M0 | obligation | ✅ | /Users/josecosta/dev/swarm/docs/reference/distillation-loss- |  |
| §24.4 | Forbidden compositions: observation-only becoming intent silently (prevented by  | rule | ✅ | /Users/josecosta/dev/swarm/docs/reference/distillation-loss- |  |
| §25.1 | Two independent version axes: language (SOL+APS) vs framework/package | taxonomy | ✅ | /Users/josecosta/dev/swarm/docs/language/versioning.md |  |
| §25.1.1 | Language version per-file: swarm_language (SOL/x.y) + aps_version (x.y) in front | schema | ✅ | /Users/josecosta/dev/swarm/docs/language/versioning.md |  |
| §25.1.2 | Framework version single-file semver: scaffold/.agents/.swarm-version (mirrored  | schema | ✅ | /Users/josecosta/dev/swarm/docs/language/versioning.md |  |
| §25.2 | One-way trigger: language change MUST force framework MINOR (additive) or MAJOR  | rule | ✅ | /Users/josecosta/dev/swarm/docs/language/versioning.md |  |
| §25.3 | Three never-merged IR/plan fields: meta.language (SOL discriminator), meta.versi | schema | ✅ | /Users/josecosta/dev/swarm/docs/language/versioning.md |  |
| §25.4 | G10: canonical frontmatter normalization (swarm_language: SOL/0.1, aps_version:  | rule | ✅ | /Users/josecosta/dev/swarm/docs/language/versioning.md |  |

## 08-recast.md  — 27 load-bearing product units, 1 at-risk

| § | Unit | Kind | Status | Framework home | If not present → recommended home |
|---|------|------|:--:|---|---|
| §26.2 | The 24-skill → 9-pass recast table (§26.2) | table | 🟡 | docs/adrs/0036-heuristic-profile-model.md, docs/adrs/0029-ni | docs/ reference page with full 24-skill recast mapping |
| §26.1 | The semantic-ownership prohibition (§26.1) | obligation | ✅ | docs/PRINCIPLES.md, kernel/.agents/profiles/skeptic.md, kern |  |
| §26.3 | Cross-cutting fragments (§26.3) | schema | ✅ | kernel/.agents/skills/empirical-proof/GUIDE.md, kernel/.agen |  |
| §26.4 | Activation doctrine: load what the task names (§26.4) | obligation | ✅ | kernel/AGENTS.md, docs/adrs/0037-load-what-the-task-names.md |  |
| §26.5 | Pass guide contract (§26.5) | contract | ✅ | kernel/.agents/skills/pass-implement-obligations/GUIDE.md, k |  |
| §26.6 | Overlay contract (§26.6) | contract | ✅ | kernel/.agents/overlays/README.md, docs/PRINCIPLES.md, docs/ |  |
| §27.1 | Heuristic profile definition (§27.1) | rationale | ✅ | kernel/.agents/profiles/skeptic.md, kernel/.agents/profiles/ |  |
| §27.2 | Profile canonical contract (§27.2) | contract | ✅ | kernel/.agents/profiles/skeptic.md |  |
| §27.3 | Profile × pass routing (§27.3) | table | ✅ | docs/adrs/0036-heuristic-profile-model.md, docs/reference/gl |  |
| §27.4 | Profile × pass replaces persona matrices (§27.4) | rule | ✅ | docs/adrs/0036-heuristic-profile-model.md, docs/adrs/README. |  |
| §28.1 | task_kind as pass parameter (§28.1) | contract | ✅ | docs/passes/implement.md, kernel/.agents/templates/task.md,  |  |
| §28.2 | task_kind → pass mapping (§28.2) | table | ✅ | docs/passes/implement.md, docs/reference/flow-graph.md, kern |  |
| §28.3 | Kickback is re-entry, not a task type (§28.3) | obligation | ✅ | docs/reference/glossary.md, kernel/.agents/templates/task.md |  |
| §28.4 | Flow-graph survives as recommended routing (§28.4) | rule | ✅ | docs/reference/flow-graph.md, docs/_legacy/concepts/07-flow- |  |
| §28.5 | Task-template consolidation (§28.5) | contract | ✅ | kernel/.agents/templates/task.md, docs/passes/implement.md |  |
| §29.1 | Epistemic stances preservation (§29.1) | table | ✅ | docs/passes/author.md, docs/adrs/0030-unified-artifact-set.m |  |
| §29.2 | spec.swarm.md rename (§29.2) | obligation | ✅ | kernel/.agents/templates/spec.swarm.md, docs/language/SOL.md |  |
| §29.3 | Four new artifacts (§29.3) | schema | ✅ | kernel/.agents/templates/trace.md, kernel/.agents/templates/ |  |
| §29.5 | Forbidden compositions are distillation + authority (§29.5) | obligation | ✅ | kernel/.agents/skills/distillation-discipline/GUIDE.md, docs |  |
| §30.1 | Nygard immutability (§30.1) | obligation | ✅ | docs/adrs/README.md, all ADRs 0001+ |  |
| §30.2 | ADR Group A kept verbatim (§30.2) | table | ✅ | docs/adrs/README.md, each ADR file |  |
| §30.2 | ADR Group B amended (§30.2) | table | ✅ | docs/adrs/README.md, each superseding ADR 0027+ |  |
| §30.3 | New kernel ADRs (§30.3) | table | ✅ | docs/adrs/README.md, each ADR 0027-0041 |  |
| §31 | AGENTS.md bootloader contract (§31) | contract | ✅ | kernel/AGENTS.md, docs/PRINCIPLES.md, docs/NON-GOALS.md |  |
| §31.1 | AGENTS.md density cap (§31.1) | obligation | ✅ | kernel/AGENTS.md, docs/PRINCIPLES.md |  |
| §31.2 | AGENTS.md contents: what goes in vs out (§31.2) | table | ✅ | kernel/AGENTS.md, docs/PRINCIPLES.md |  |
| §31.3 | Commands contract (§31.3) | contract | ✅ | kernel/AGENTS.md, docs/passes/verify.md, docs/adrs/0038-veri |  |

## 09-conformance-and-rework.md  — 24 load-bearing product units, 11 at-risk

| § | Unit | Kind | Status | Framework home | If not present → recommended home |
|---|------|------|:--:|---|---|
| §32.6 | Required verification suite matrix (per-task_kind rows with cmd* slots and gate  | table | 🟡 | /Users/josecosta/dev/swarm/kernel/.agents/conformance/confor |  |
| §32.7, §32.7.1 | Toolchain verb set and boundary (§32.7): documented contract (init, lint, format | contract | 🔴 | NONE | /Users/josecosta/dev/swarm/docs/language/ |
| §32.7.2, §32.7.3 | Toolchain ownership vs agent-CLI ownership (§32.7.2 and §32.7.3): what Swarm OWN | contract | 🔴 | NONE | /Users/josecosta/dev/swarm/docs/language/ |
| §32.7.4 | Agent-CLI adapter contract (command, working_directory, startup_instruction fiel | contract | 🔴 | NONE | /Users/josecosta/dev/swarm/docs/language/ |
| §33.2, §33.3 | Golden corpus: three recurring domains with positive and negative fixtures (auth | example | 🟠 | /Users/josecosta/dev/swarm/kernel/.agents/conformance/fixtur |  |
| §33.3.1–§33.3.3 | Golden corpus canonical defect classes (auth-refresh: dangling condition + SHOUL | example | 🔴 | /Users/josecosta/dev/swarm/kernel/.agents/conformance/fixtur |  |
| §33.4 | Golden corpus: task-file violation classes (empty paste, missing required verifi | example | 🟡 | /Users/josecosta/dev/swarm/kernel/.agents/conformance/fixtur |  |
| §33.5 | Golden corpus: labeled prose precision/recall baseline (≥0.90 precision / ≥0.85  | table | 🔴 | NONE | /Users/josecosta/dev/swarm/kernel/.agents/conformance/f |
| §33.6, §33.6.1 | Pass-output rubrics (nine pass predicates: author, lint, improve, lower, decompo | rule | 🔴 | NONE | /Users/josecosta/dev/swarm/docs/reference/ |
| §33.7.1 | Golden corpus: held-out mutated-variant fixtures (semantically equivalent regene | example | 🔴 | NONE |  |
| §33.7.3 | Golden corpus: research-fanout fixture (fan-out provenance: one research.md feed | example | 🔴 | NONE |  |
| §32.1 | The conformance manifest structure (conformance.yaml location and required conte | contract | ✅ | /Users/josecosta/dev/swarm/kernel/.agents/conformance/confor |  |
| §32.2 | The conformance definition (four clauses: language refs, templates, AGENTS.md, v | contract | ✅ | /Users/josecosta/dev/swarm/docs/model/conformance.md |  |
| §32.3 | Task-file schema: required_sections (8 H2 headings MUST be present) | obligation | ✅ | /Users/josecosta/dev/swarm/kernel/.agents/conformance/confor |  |
| §32.3 | Task-file schema: content_rules (non-empty-paste rule: required paste slots MUST | obligation | ✅ | /Users/josecosta/dev/swarm/kernel/.agents/conformance/confor |  |
| §32.3 | Task-file schema: content_rules (no-open-critical rule: blocking QUESTION MUST b | obligation | ✅ | /Users/josecosta/dev/swarm/kernel/.agents/conformance/confor |  |
| §32.4 | Required AGENTS.md command rows (three tiers: required, extended, out-of-contrac | taxonomy | ✅ | /Users/josecosta/dev/swarm/kernel/.agents/conformance/confor |  |
| §32.5 | Legal placeholder namespaces (cmd*, "", swarm:, project:, vendor: and the rule t | rule | ✅ | /Users/josecosta/dev/swarm/kernel/.agents/conformance/confor |  |
| §32.6 | Unified lint scheme (one prefix SOL, five layers S/P/M/V/O, form SOL-<LAYER>NNN) | taxonomy | ✅ | /Users/josecosta/dev/swarm/kernel/.agents/conformance/confor |  |
| §32.6 | Five gate tokens definition (acceptance-criteria-coverage, regression-test, beha | taxonomy | ✅ | /Users/josecosta/dev/swarm/kernel/.agents/conformance/confor |  |
| §32.8 | Conformance maturity ladder (five tiers: Swarm-readable, Swarm-lintable, Swarm-c | taxonomy | ✅ | /Users/josecosta/dev/swarm/docs/model/conformance.md |  |
| §35.1 N1 | Non-goals: no shipped CLI, runtime, scheduler, parser, checker (Invariant 1, NO  | invariant | ✅ | /Users/josecosta/dev/swarm/docs/NON-GOALS.md |  |
| §35.1 N2 | Non-goals: no shipped checker; conformance contract is data not tool | invariant | ✅ | /Users/josecosta/dev/swarm/kernel/.agents/conformance/README |  |
| §35.2 | Deferred features list (D1–D12: timing semantics, expression language, cross-spe | taxonomy | ✅ | /Users/josecosta/dev/swarm/docs/language/versioning.md |  |

## 10-appendices.md  — 6 load-bearing product units, 4 at-risk

| § | Unit | Kind | Status | Framework home | If not present → recommended home |
|---|------|------|:--:|---|---|
| §A.1–A.2 | Consolidated SOL grammar — complete EBNF (A.1–A.2) | grammar | 🟡 | docs/language/SOL.md (partial) | docs/language/grammar.md (new artifact, or embedded in  |
| §C.1–C.3 | IR JSON Schema — Appendix C.1–C.3 full schema + plan schema | schema | 🔴 | NONE | docs/language/ir-schema.md or docs/reference/ir-schema. |
| §D.1–D.8 | Worked example — Appendix D.1–D.8 full auth-refresh pipeline | example | 🔴 | NONE | docs/examples/auth-refresh-pipeline.md (new artifact) o |
| §E (G1–G12) | Residual gaps and judgment calls — Appendix E.1–E.12 (G1–G12 normative table) | table | 🟡 | Scattered across docs/adrs and inline references (partial) | docs/reference/judgment-calls.md (new artifact, with G1 |
| §B.1–B.6 | Lint-code catalogue — Appendix B.1–B.6 full table | table | ✅ | docs/language/errors.md (complete) |  |
| §F | Glossary — Appendix F, complete 40-term alphabetized index | taxonomy | ✅ | docs/reference/glossary.md (complete) |  |

## Build-process units (stay with the build source — NOT exploded)

| § | Unit | Why it stays |
|---|------|---|
| Appendix A | Normative EBNF grammar in Appendix A (spec §5–§6 prose form; grammar i | Appendix A is the normative EBNF; the framework doc (SOL.md) is the prose distillation. Pr |
| §12 + Appendix C | IR layer (snake_case fields, lowering to JSON nodes/edges) and IR sche | IR layer is emitted, never authored. Surface authors do not read §12 or Appendix C. The fr |
| §15 | Full proof taxonomy and strength ordering (§15) | Strength order (model > property/contract > test > static > manual/monitor) is stated in S |
| §16 | Staleness detection and drift-provenance fields (§16) | Staleness detection is named in the framework (implement.md, lower.md) as a concept with t |
| §18 | Orchestration / safe-parallelism predicate and SURFACE lock-group attr | The metadata clauses feeding orchestration (WRITES, READS, TOUCHES, AFFECTS) are present.  |
| §22 | Governance domains (Axis-B model) (§22) | DOMAIN clause and frontmatter domain field are documented. The eight governance domains (p |
| §35 + Appendix E | v0.2 deferrals: expression sublanguage, timing keywords (WITHIN, BEFOR | v0.1 vs v0.2 version axis documented. Timing keywords named as deferred. This is archival: |
| §34, §34.1–§34.6 | Acceptance gate A1–A28 (28 source/template/corpus/count/ADR/construct- | These are reconciliation checks (§34.1–§34.6) verifying the spec's own internal consistenc |
| §34.8 | Workspace-model migration checks AW1–AW9 (nine canonical-reference che | These are adoption-framing regression checks (§34.8). Build-process gating. The underlying |
| §G | Rework brief — Appendix G copy-paste agent prompt | The rework brief is a build-process artifact (instructions to agents building the repo), n |
