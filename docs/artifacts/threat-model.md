# Artifact: `threat-model.md` (conditional)

> Swarm's reference for the `threat-model.md` source-doc: the **conditional, security-domain** source artifact whose modelled threats promote forward into obligations.

A `threat-model.md` is a **conditional Tier-3 source-doc** the stdlib SHOULD make available for any change whose domain is `security` or that touches an attack surface (mapped to OWASP-LLM01). It is the security-flavoured sibling of `audit.md`: it records threats observed against a surface, and those threats become binding only after an `author` pass restates them as obligations.

## Purpose & epistemic stance

- **Stance: threat observation, not intent.** A `threat-model.md` records *what could go wrong* on a surface. It MUST NOT carry its own `REQ`/`CONSTRAINT`/`INVARIANT`/`INTERFACE` obligation blocks — observed threat is promoted *into* a spec, where it acquires obligation force. (Same epistemic-stance rule as `audit.md` and `bug-report.md`.)
- **Conditional — never conformance-required.** It sits **outside** the five-template Tier-3 inventory the conformance definition counts. A conformant kernel MAY ship it as an optional security extension; a conformant repository MAY have zero instances. Its absence is never a conformance failure.
- **Externally-informed.** Because a threat model draws on outside knowledge (advisories, CVEs, attacker models), an obligation it implies is subject to the source-authority rule for externally-authored sources before it becomes binding — it is corroborated, not auto-trusted.

## Filename & placement

Plain `.md` (a working source artifact — **no** `.swarm.` infix). In an adopted project it lives under `.swarm/sources/` (alongside the other source-docs). It carries `type` + `id` frontmatter and no obligation blocks.

## Required sections

| Section | Meaning |
| --- | --- |
| frontmatter | `type: threat-model`, `id`. |
| `## Scope` | the surface / asset / trust boundary being modelled. |
| `## Threats` | one row per modelled threat: an id, the threat, its category (e.g. STRIDE / OWASP-LLM), and cited evidence. No obligation language. |
| `## Threats to promote` | for each threat, the obligation it SHOULD become on promotion — stated as a *proposal* (actor + the limit), not as an authored `CONSTRAINT`/`INVARIANT` block. |

## Promotion

A `threat-model.md` promotes forward only through an `author` pass that restates each modelled threat as a `CONSTRAINT`/`INVARIANT` with its own id, modality, and a `VERIFY BY` binding — typically a `security` proof. It never becomes intent in place.

## Copyable template

The skeleton is `starter-kit/.agents/templates/threat-model.md`. That file is the copyable skeleton; this page is its contract.

## Related

- [`audit.md`](./audit.md) — the general observation-only source-doc this mirrors for the security domain.
- [`spec`](./spec.md) — what a threat promotes *into* (via the [`author`](../passes/author.md) pass).
- [`source-artifacts`](../model/source-artifacts.md) — where the conditional Tier-3 source-docs are catalogued.
- [`proof-types`](../reference/proof-types.md) — the `security` proof type a promoted threat binds to.
