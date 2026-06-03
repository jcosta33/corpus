# Execution drift: why steps inside a loaded guide get skipped

A pass guide that is loaded is not the same as a pass guide that runs to its end. Loading is upstream: the kernel's primary mechanism is **load what the task names** — a `task.md` names the pass guide(s) and profile(s) for the pass it frames, and the agent loads exactly those (description-match self-activation is the launcher-less fallback, not the primary loader; see [the loading doctrine](../library/pass-guides.md#the-loading-doctrine-load-what-the-task-names) and [ADR-0037](../adrs/0037-load-what-the-task-names.md)). This page is about the *downstream* failure: once the right guide is in context, late steps inside it — especially the verification steps that produce only a yes/no result — get **silently skipped**, and the final output still looks complete. Swarm's structural defence is to force those steps to emit a marker a later reader can see. This page grounds that defence on a verified result and ties it to the kernel's empirical-proof rule.

---

## Two failure modes, not one

It is tempting to treat reliability as a single problem — "did the agent do the right thing?" — but the failures live in two distinct places, and they have opposite visibility.

| Mode | Where it happens | Visible to the user? | Visible in the session log? |
| --- | --- | --- | --- |
| **Loading failure** | The pass guide the task needs is never in context. | Yes — the agent works without the guide's discipline; the structure of the output differs. | Yes — the guide was never loaded. |
| **Execution drift** | The guide is loaded, early steps run, but a late step that produces only an implicit result is quietly dropped. | **No** — the output looks complete; the verification claim is asserted but the proof was never produced. | Sometimes — only if a reviewer checks specifically for the missing marker. |

The two-failure-mode framing is illustrated — *as a preliminary, non-peer-reviewed practitioner observation* — by [TWOPROBLEMS](sources.md#TWOPROBLEMS), which distinguishes a guide failing to activate from a guide whose later steps are skipped after it loads. We use it only to name the shape of the problem; the load-bearing version of the fix below rests on a peer-reviewed result and the kernel's own proof rule, not on that source's figures (it reports none we rely on).

Loading failures are loud: the work has the wrong shape and a re-prompt recovers it. Execution drift is quiet: the answer arrives, the structure looks right, the verification *claim* is present — and the bound proof was never run. The forced-visible-output discipline is the cheapest available defence against the quiet mode, because it converts an invisible omission into a conspicuous one.

---

## The fix: force the invisible step to emit a visible marker

The pattern is one sentence: **if a step's compliance is otherwise invisible, require it to produce a marker the next reader — agent or human — can see.** A verification step that yields only "it passed" produces nothing a reviewer can re-check, so it is the easiest step to drop without anyone noticing. Requiring it to paste its evidence removes the option of dropping it silently.

In the kernel this is **not a runtime check** — Swarm ships no runtime, and every "checker" named here is a contract a future tool would build against (see the soft/hard control boundary in [the `verify` pass, §7](../passes/verify.md#7-the-softhard-control-boundary)). The marker is what makes the omission conspicuous in markdown today; it does not make the property hold. That honesty is the whole point: a markdown layer can make a gap visible, it cannot enforce its closure.

### The empirical-proof rule is the canonical instance

The kernel's [empirical-proof fragment](../library/pass-guides.md#the-two-cross-cutting-fragments) carries exactly this discipline behind the `verify` and `review` passes. Its load-bearing rule is the kernel's own:

> **"Tests passed" without output is invalid.** A `PASS` whose `EVIDENCE` is the bare phrase "tests passed" — no command, exit code, run output, or selector resolution — is **`UNVERIFIED`**, not `PASS`.

That rule lives in the language reference, not in the fragment: [the `verify` pass, §5.8](../passes/verify.md#58-what-is-not-a-proof) defines what is *not* a proof, and the empirical-proof fragment only carries the *procedure* for applying it (a fragment defines no semantics — see [pass guides](../library/pass-guides.md#the-two-cross-cutting-fragments)). The same prohibition appears on the production side: an `implement` TRACE's `PROOF` line "MUST reference real output: an unqualified 'tests passed' is not admissible" ([the `implement` pass](../passes/implement.md#the-output-the-tracemd-claim-contract-214)). A completion claim with no pasted evidence is precisely the late-step-skipped failure made visible: the verdict drops to `UNVERIFIED` instead of slipping through as a `PASS`.

This generalises past code. A `manual` verdict without recorded reasoning is `UNVERIFIED`; schema-valid output is not a proof, because shape is not truth ([§5.8](../passes/verify.md#58-what-is-not-a-proof)). In every case the rule is the same: a claim that cannot show its work does not count, and the forced marker is what exposes the gap.

---

## Why a written marker is a learning signal, not just a tripwire

Forcing visible output is more than a tripwire against a skipped step — it is the same mechanism that makes language agents *improve*. [REFLEXION](sources.md#REFLEXION) (Shinn et al., NeurIPS 2023) measured it directly: agents that wrote a verbal self-reflection between failed attempts and re-read it on the next attempt reached **91% pass@1 on HumanEval against the 80% GPT-4 baseline** — a gain attributable to the *written* reflection, not to extra model capability. The trick is that a verbal artefact converts an implicit signal into a durable, checkable one.

The structural parallel is exact:

```text
REFLEXION (per trial):
  attempt -> failure -> verbal reflection (written down) -> next attempt reads it

Forced-visible-output (per verification step):
  step fires -> output is required -> output is pasted verbatim -> next reader sees the marker
```

In both loops the durable artefact does the work. An agent that *holds* the result in attention performs worse than one that *writes it down* — REFLEXION shows the written reflection is what moves the score, and the kernel's externalisation disciplines (the task file, the `trace.md`, the per-binding `EVIDENCE` clause) are the per-step version of the same move. This is why the kernel keeps execution state out of the model's head and on disk in `task.md` and the `.swarm/` workspace (`sources/`, `status/`, `generated/`; see [the workspace model](../model/workspace.md#the-source--status--generated-split)): a signal that is only in attention is a signal that can be silently dropped, exactly the way a late step is.

This grounding stands on REFLEXION alone. A "21× file-state degradation" figure attributed to an "InfiAgent" paper circulates in the skill-authoring literature; that arXiv id was found to resolve to an unrelated condensed-matter physics paper and is **rejected** (see [sources.md, Rejected](sources.md#rejected--do-not-cite-fabricated--misattributed)). The externalisation point is instead carried by REFLEXION plus the kernel's verified context-engineering guidance — no fabricated multiplier is needed to make it.

---

## How the forced marker rides each pass

The marker is not a single skill's quirk; it is wired into the pass-and-proof contract, so any pass with a verification step inherits it.

| Surface | The forced marker | The drift it closes |
| --- | --- | --- |
| `verify` pass / empirical-proof fragment | A `PASS` MUST carry an `EVIDENCE` clause with command, exit, and run output — never a bare "tests passed". | A verification step asserted but never run. |
| `implement` pass `trace.md` | Every `TRACE` that `IMPLEMENTS` MUST carry at least one `PROOF` line referencing real output. | A claimed implementation with no evidence behind it. |
| `review` pass | Each required `VERIFY BY` binding gets exactly one `VERDICT`; a missing one is `UNVERIFIED` at the merge gate. | A binding quietly left unjudged. |

These are SOFT-control markers: they make the gap *conspicuous*, and a future deterministic check (a CI gate, a merge-blocking status) is the only thing that could make closing it *mandatory* (the enforcement-lane ledger in [the `verify` pass, §8](../passes/verify.md#8-the-enforcement-lane-artifact) is where each such obligation records its eventual deterministic home). The kernel's loading doctrine and density discipline keep the *upstream* failure rare — load only what the task names, keep the always-loaded AGENTS.md bootloader under its ≤200-line / ≤25 KB cap so the right context is present and uncrowded (the cap's rationale is [LOSTMID](sources.md#LOSTMID)'s lost-in-the-middle curve traded against gap-filling, not a capability-ceiling claim). The forced marker closes the *downstream* one.

---

## See also

- [Sources](sources.md) — the verified bibliography; [REFLEXION](sources.md#REFLEXION), [LOSTMID](sources.md#LOSTMID), and the caveated [TWOPROBLEMS](sources.md#TWOPROBLEMS) ground this page.
- [The `verify` pass](../passes/verify.md) — the verdict model, the proof taxonomy, the "what is not a proof" rule (§5.8), and the soft/hard control boundary (§7).
- [The `implement` pass](../passes/implement.md) — the `trace.md` `PROOF`-line contract that forbids unqualified "tests passed".
- [Pass guides](../library/pass-guides.md) — the empirical-proof and distillation-discipline fragments, and the loading doctrine that governs the upstream (loading) failure mode.
- [The workspace model](../model/workspace.md) — `task.md` plus the `.swarm/` source/status/generated split, where externalised execution state lives.
- [Heuristic profiles](../library/heuristic-profiles.md) — the Skeptic stance applied to `review`/`verify`, whose `## Refuses` table rejects unproven completion claims.
