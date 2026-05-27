---
name: library-reference-distillation
description: Methodology for starting a new library-reference distillation skill — one that turns an external library (nuqs, zod, framer-motion, msw, react-hook-form, emilkowal-animations) into an idiomatic-usage rule pack — or evolving one against a new upstream release. Distills the conventions empirically shared across shipped library-ref skills in this repo — the source-priority ladder (docs → blog/changelog → issues → types → examples), version pinning that inverts with API velocity, the universal 4-tier category ladder (CRITICAL setup → HIGH isolation → MEDIUM composition → LOW edge cases), the 4-slot When-to-Apply template, the failure-gap exemplar heuristic (privilege production lessons over API restatement), and metadata.references[] as cite-set checksum. Triggers on "I want to write a skill for library X", "refresh against new upstream", "where should I source rules from", "what categories should this skill have", and on /dev-skill:new for a library-reference distillation.
---
# Library-Reference Distillation — Archetype Playbook

Methodology distillation of the conventions that hold across shipped **library-reference distillations** in this repo — the archetype that turns one external library into an idiomatic-usage rule pack. Not a generator; a constraint set on the editorial decisions `/dev-skill:new` cannot make for you.

This is the **archetype layer** that sits above `/dev-skill:new` and `/dev-skill:ingest`. The generator handles the structural shell. This skill handles the four decisions you re-make for every library-ref skill: where to source from, how to pin against version drift, how to shape categories and rules, and how to keep the metadata an honest checksum.

## When to Apply

Use this skill when:

- Starting a new library-ref distillation (the library has docs and a stable surface area you want to capture as idiomatic rules)
- Evolving an existing library-ref skill against a new upstream release or major version bump
- Reviewing a draft library-ref skill that "feels like the docs rewritten"
- Picking categories and a prefix scheme for a new skill and the choices feel arbitrary
- Deciding whether to pin the upstream version in `SKILL.md` heading or only in `metadata.json`
- Refreshing a skill where you suspect rule drift from upstream (the `openai-codex-rust-patterns` lesson: codex-rs drifts hard between snapshots)

This skill is **not** for:

- **Code-atlas distillations** (e.g., `openai-codex-rust-patterns`, `opencode-ts`, `nextjs-ppr-patterns`) — sources are a real repo at a pinned HEAD, not upstream docs. Sibling archetype playbook still to be extracted.
- **Methodology distillations** (e.g., `radical-simplification`, `deterministic-metric-design`) — sources are named humans and their canon, not a library.
- **Scaffolders** (e.g., `expo-design-system-scaffolder`) — composition workflow, not a rulebook.

## How to Use

The four categories are orthogonal decisions you make once per skill. Match the symptom to the move:

| Symptom | Reach for | First rule to read |
|---------|-----------|--------------------|
| Don't know where to mine rules from | **Source** | [`source-priority-ladder`](references/source-priority-ladder.md) |
| Rules feel like API restatement, not load-bearing | **Source** (failure-gap) | [`source-failure-gap`](references/source-failure-gap.md) |
| Library changes fast — skill will rot | **Pin** | [`pin-by-velocity`](references/pin-by-velocity.md) |
| Existing skill is drifting from upstream | **Pin** (refresh) | [`pin-refresh-vs-head`](references/pin-refresh-vs-head.md) |
| Categories feel arbitrary | **Shape** | [`shape-category-ladder`](references/shape-category-ladder.md) |
| When-to-Apply does not trigger reliably | **Shape** (When-to-Apply) | [`shape-when-to-apply-template`](references/shape-when-to-apply-template.md) |
| Cite list and rule sources have drifted | **Meta** | [`meta-references-checksum`](references/meta-references-checksum.md) |

For category overviews and ordering rationale, see [`references/_sections.md`](references/_sections.md).

## Rule Categories

| # | Category | Prefix | Move | Rules |
|---|----------|--------|------|-------|
| 1 | Source Selection | `source` | Where to mine from; what makes a rule load-bearing | 2 |
| 2 | Versioning | `pin` | How to pin against API velocity; how to refresh | 2 |
| 3 | Rule Shape | `shape` | The universal 4-tier ladder; the When-to-Apply template | 2 |
| 4 | Metadata Discipline | `meta` | references[] as honest cite-set checksum | 1 |

## Quick Reference

### 1. Source Selection

- [`source-priority-ladder`](references/source-priority-ladder.md) — Docs → blog/changelog → GitHub discussions → types → examples; the ladder inverts only when the library publishes an `llms.txt` (Effect)
- [`source-failure-gap`](references/source-failure-gap.md) — Privilege rules that capture what docs omit and production exposed; if a rule just restates the API, cut it

### 2. Versioning

- [`pin-by-velocity`](references/pin-by-velocity.md) — Stable APIs (Zod, RHF) → version lives in `metadata.json` only; fast-moving APIs (nuqs v2.5–v2.8, Tailwind v4) → explicit range in `SKILL.md` heading
- [`pin-refresh-vs-head`](references/pin-refresh-vs-head.md) — When evolving, diff your skill against upstream HEAD; codify the drift lessons (codex-rs `codex.rs` → `session/` split is the canonical example)

### 3. Rule Shape

- [`shape-category-ladder`](references/shape-category-ladder.md) — Every shipped library-ref skill ladders CRITICAL setup → HIGH isolation/perf → MEDIUM composition/integration → LOW edge cases/polish; pick category names that map onto this, do not invent a new shape
- [`shape-when-to-apply-template`](references/shape-when-to-apply-template.md) — 4 slots: import-statement trigger + problem-domain language + frequency signal + explicit NOT-to-do boundary pointing to sibling skills

### 4. Metadata Discipline

- [`meta-references-checksum`](references/meta-references-checksum.md) — `metadata.references[]` is the exact set of URLs cited in rules — no superset, no subset; if it diverges, either the rules or the metadata is lying

## Related Skills

- [`radical-simplification`](../radical-simplification/SKILL.md) — The thinking layer above this skill; this playbook is itself an instance of the "reduce → constrain → name the invariant" moves applied to skill-authoring
- [`skill-authoring`](../../.curated/skill-authoring/SKILL.md) — Cross-archetype skill-authoring conventions; this skill is the library-reference specialization
- [`deterministic-metric-design`](../deterministic-metric-design/SKILL.md) — Methodology-distillation sibling; demonstrates the same archetype patterns applied to a different archetype (proves the per-archetype playbook idea generalizes)

## Authoring Note

These rules are **load-bearing**, not decorative. They were extracted by tracing where rules in 5 shipped library-ref skills cited their sources (nuqs, zod, react-hook-form, effect-ts, emilkowal-animations). Each rule names the wrong default the author makes when these conventions are absent. If a rule restates something `/dev-skill:new` already handles, cut it. Coverage is proven by `/dev-skill:eval` on real library-distillation prompts, not by rule count. When the next archetype playbook (code-atlas, methodology, scaffolder, runbook) is extracted, the patterns that re-appear here are candidates for promotion to a generic `skill-authoring` skill; the ones that diverge stay archetype-specific.
