---
name: docs-search
description: Use this skill when an agent needs to look up an answer in a library's official documentation — API behavior, version-specific changes, idiomatic usage, or why production diverges from docs — independent of which library. Distills the generic navigation moves shared across libraries — classify the question before searching (changelog vs API reference vs idiom vs known-bug), check llms.txt before scraping HTML, pin to the user's version before reading reference pages, read changelog first for "did X change" questions, treat examples/ dirs as truth for idioms, and fall back to GitHub issues / status page / Discord when docs match but reality doesn't. Per-library topography lives in the shared /knowledge/libraries/ graph as thin reference data, alongside code-distill's section. Triggers on "where in <library> docs", "look this up in <library>", "did <library> change X", "docs say X but code does Y", and any prompt where the next move is to consult a library's official documentation.
---

# Docs Search — Navigation Methodology for Official Library Documentation

Methodology distillation of the generic moves an agent makes when reaching for a library's official documentation. Not a per-library skill — one skill plus a thin per-library record in the shared knowledge graph ([`/knowledge/libraries/`](../../../knowledge/)), because 90% of the work is the same regardless of which library you're searching.

This is the **navigation layer** that sits next to [`library-reference-distillation`](../library-reference-distillation/SKILL.md). That skill is for *authoring* a full library-ref rule pack when you have time to extract idioms. This skill is for *just looking something up* when you don't — a lighter-weight, faster-to-author alternative whose unit of growth is a ~30-line topography record, not a full rule pack.

## When to Apply

Use this skill when:

- An agent needs a specific answer from a library's official documentation and "search the docs" is the next move
- The user asks "where do I find X in `<library>` docs?" or "did `<library>` change Y recently?"
- The documentation appears to match the situation but production behavior diverges
- The agent is about to Google a library question and would benefit from going to the library's own site search, llms.txt, or changelog first
- A library has been used before and a topography record exists in `registry/` — read it before navigating
- A library has been used and no record exists yet — apply the methodology, then capture findings in `registry/<library>.md` so the next lookup is faster

This skill is **not** for:

- **Authoring a library-reference rule pack** — when you want to extract idioms and failure-gap rules into a distilled skill, use [`library-reference-distillation`](../library-reference-distillation/SKILL.md) instead. Once a full library-ref skill exists for library X, the registry entry for X becomes redundant and should be cut.
- **General web search** — if the question is not about a specific library's official docs (e.g., "what's the best practice for X across the ecosystem"), this is the wrong tool.
- **Reading internal/proprietary docs** — no llms.txt, no public changelog, no public issues. The methodology assumes public, versioned, OSS-style documentation.

## How to Use

The four categories are orthogonal moves. Match the symptom to the move:

| Symptom | Reach for | First rule to read |
|---------|-----------|--------------------|
| Question is vague — "search the docs for X" | **Choose Source** | [`src-decision-tree`](references/src-decision-tree.md) |
| About to scrape HTML; haven't checked for AI-canonical format | **Choose Source** (llms.txt) | [`src-llms-txt-first`](references/src-llms-txt-first.md) |
| About to scan knowledge/libraries/ before reading the named entry | **Choose Source** (bounded read) | [`src-bounded-knowledge-read`](references/src-bounded-knowledge-read.md) |
| Reading latest docs but user may be on older version | **Match Version** | [`ver-find-selector`](references/ver-find-selector.md) |
| Question is "did X change since I upgraded?" | **Match Version** (changelog) | [`ver-changelog-first`](references/ver-changelog-first.md) |
| Docs match but production behavior doesn't | **Fall Back** | [`fall-known-issues`](references/fall-known-issues.md) |
| Question is "how should I structure this idiomatically?" | **Fall Back** (samples) | [`fall-samples-over-prose`](references/fall-samples-over-prose.md) |
| Found the canonical entry points — about to move on | **Capture for Reuse** | [`capture-registry-record`](references/capture-registry-record.md) |

For category overviews and ordering rationale, see [`references/_sections.md`](references/_sections.md).

## Rule Categories

| # | Category | Prefix | Move | Rules |
|---|----------|--------|------|-------|
| 1 | Choose Source | `src` | Classify the question; check llms.txt; bounded read of knowledge | 3 |
| 2 | Match Version | `ver` | Pin to the user's version; consult changelog before reference | 2 |
| 3 | Fall Back | `fall` | Known issues when docs contradict reality; examples over prose for idioms | 2 |
| 4 | Capture for Reuse | `capture` | Record topography in registry/ so the next lookup is faster | 1 |

## Quick Reference

### 1. Choose Source

- [`src-decision-tree`](references/src-decision-tree.md) — Classify the question (API behavior / changelog / idiom / known-bug / migration) before picking a section; "search the docs" is not a plan
- [`src-llms-txt-first`](references/src-llms-txt-first.md) — Probe `<docs-root>/llms.txt` or `/llms-full.txt` before scraping HTML; AI-canonical format if it exists
- [`src-bounded-knowledge-read`](references/src-bounded-knowledge-read.md) — Filename is the index: read only `knowledge/libraries/<slug>.md`, never scan the dir; bounds per-invocation token cost regardless of knowledge-store size

### 2. Match Version

- [`ver-find-selector`](references/ver-find-selector.md) — Find the version selector before reading any reference page; ask the user or read `package.json` to pin
- [`ver-changelog-first`](references/ver-changelog-first.md) — When the question contains "since I upgraded" or "did X change", read the changelog before the reference

### 3. Fall Back

- [`fall-known-issues`](references/fall-known-issues.md) — When docs match the user's code but reality doesn't, check GitHub issues, status page, and Discord/forum for known bugs before re-reading docs
- [`fall-samples-over-prose`](references/fall-samples-over-prose.md) — For "how should I structure this?" go to the `examples/` dir or samples repo first; idiomatic structure lives in code, not prose

### 4. Capture for Reuse

- [`capture-registry-record`](references/capture-registry-record.md) — After a successful lookup against a new library, write the `docs:` section of `knowledge/libraries/<library>.md` so future lookups skip the discovery phase

## Knowledge Store

Per-library topography records live in the repo-root shared knowledge graph at [`/knowledge/libraries/`](../../../knowledge/libraries/). The same files are written by [`code-distill`](../code-distill/SKILL.md) — each skill owns one section (`docs:` for this skill, `code:` for `code-distill`) and never overwrites the other. See [`knowledge/README.md`](../../../knowledge/README.md) for the merged schema, wiki-link conventions, and the merge discipline.

The knowledge store is **intentionally empty at v0.1.0**. First entries are added when a real lookup demands one, not pre-emptively. If you find yourself adding a record for a library you have not actually queried, stop — wait for the real need.

**Read discipline**: when the user names a library, do exactly `read knowledge/libraries/<slug>.md`. Never scan `knowledge/libraries/` to "see what's available" — the filename is the index, and lazy access is what keeps per-invocation token cost bounded regardless of knowledge-store size.

## Related Skills

- [`library-reference-distillation`](../library-reference-distillation/SKILL.md) — Authoring playbook for full library-ref rule packs (the heavier sibling); when a full library-ref skill ships for library X, retire the registry entry for X
- [`radical-simplification`](../radical-simplification/SKILL.md) — The thinking layer above this skill; this skill itself is an instance of the "constrain → name the invariant" move applied to the question "how do I look this up?"
- [`init`](../../.curated/init/SKILL.md) (and similar) — When the lookup is *about your own codebase*, that's a different problem; this skill is for external library docs

## Authoring Note

These rules are **load-bearing**, not decorative. Each names a wrong default an agent has when reaching for documentation: treating all questions as "search docs," ignoring llms.txt, reading the latest reference page while the user is on an older version, re-reading docs when reality contradicts them, preferring narrative over code, and redoing lookup work next time. If a rule restates something a capable model already does correctly when prompted, cut it. Coverage is proven by `/dev-skill:eval` on real doc-lookup prompts, not by rule count. The registry grows organically as real lookups demand entries.
