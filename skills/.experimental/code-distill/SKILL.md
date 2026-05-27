---
name: code-distill
description: Use this skill to distill code patterns on demand from a specific GitHub codebase, given a focused query — "how does shadcn/ui implement the design system", "how does opencode use effect-ts", "how does base-ui handle composition" — when no pre-distilled static rule pack exists yet. Distills the generic pattern-extraction moves — classify the query before grepping (component / composition / state / effect / error / build / routing), grep before reading whole files, treat tests and examples/ as canonical intent, follow imports outward for the public surface, follow usages inward for variants, filter boilerplate / legacy / test scaffolding to surface load-bearing code, and capture findings to /knowledge/libraries/ for reuse. Dynamic light sibling of static code-atlas skills (opencode-ts, openai-codex-rust-patterns, nextjs-ppr-patterns). Triggers on "show me how <library> implements X", "find the <pattern> in <repo>", "distill <library>", and ad-hoc /distill-<library>-style invocations.
metadata:
  internal: true
---
# Code-Distill — Pattern Extraction Methodology for GitHub Codebases

Methodology distillation of the generic moves an agent makes when distilling code patterns on demand from a specific GitHub codebase, given a focused query. Not a per-library skill — one skill plus a thin per-library record in the shared knowledge graph ([`/knowledge/libraries/`](../../../knowledge/)), because 90% of the work is the same regardless of which repo.

This is the **dynamic light sibling** of your static code-atlas distillations: `opencode-ts`, `openai-codex-rust-patterns`, `nextjs-ppr-patterns`. Those skills are heavy curated outputs — they distilled patterns from a single repo ahead of time. This skill is the on-demand alternative: when no static skill exists for the library yet, point at the repo and let the methodology run.

## When to Apply

Use this skill when:

- The user asks "how does `<library>` implement `<feature>`?" and points at (or names) a real GitHub repo
- The query is focused on a single subsystem (design system, composition, state, error handling, effects, build, routing) — not "what is this whole codebase?"
- No static code-atlas skill exists for the library yet (or the existing one is stale)
- An ad-hoc invocation looks like `/distill <library> <query>` or "show me X in repo Y" in natural language
- The library has too small a surface area, or too short a lifespan, to justify authoring a full static code-atlas distillation

This skill is **NOT** for:

- **Libraries with a static code-atlas skill** — use [`opencode-ts`](../opencode-ts/SKILL.md), [`openai-codex-rust-patterns`](../openai-codex-rust-patterns/SKILL.md), [`nextjs-ppr-patterns`](../nextjs-ppr-patterns/SKILL.md), or other shipped per-library skills first. They are faster (already curated) and incorporate failure-gap lessons this skill cannot rediscover on demand.
- **Full-codebase architecture mapping** — when the question is "what does this whole codebase do, by domain?", use [`codebase-comprehension-algorithms`](../codebase-comprehension-algorithms/SKILL.md). That skill is the heavy algorithmic toolkit (Leiden, MoJoFM, SBM); this skill is focused-query extraction.
- **Authoring a full static code-atlas skill** — the methodology playbook for that authoring task is a separate (not-yet-built) skill, the code-source sibling of [`library-reference-distillation`](../library-reference-distillation/SKILL.md). When you find yourself running `code-distill` against the same library more than ~3 times, that is the signal to graduate to a full static skill.
- **Documentation lookup** — for "where do I find X in `<library>` docs?" use [`docs-search`](../docs-search/SKILL.md). This skill is for source code, not docs.

## How to Use

The four categories are orthogonal moves. Match the symptom to the move:

| Symptom | Reach for | First rule to read |
|---------|-----------|--------------------|
| About to grep blindly, query is vague | **Find** | [`find-classify-query`](references/find-classify-query.md) |
| About to read a whole file before locating the pattern | **Find** (grep) | [`find-grep-before-read`](references/find-grep-before-read.md) |
| Found a candidate file; not sure if it's idiomatic | **Find** (tests) | [`find-tests-show-intent`](references/find-tests-show-intent.md) |
| About to scan knowledge/libraries/ before reading the named entry | **Find** (bounded read) | [`find-bounded-knowledge-read`](references/find-bounded-knowledge-read.md) |
| Found the implementation; need to map its public surface | **Trace** (outward) | [`trace-imports-outward`](references/trace-imports-outward.md) |
| Have the public surface; need to see variants & evolution | **Trace** (inward) | [`trace-usages-inward`](references/trace-usages-inward.md) |
| Buried in boilerplate, legacy paths, test scaffolding | **Filter** | [`filter-load-bearing`](references/filter-load-bearing.md) |
| Done — about to close the session | **Capture** | [`capture-registry-record`](references/capture-registry-record.md) |

For category overviews and ordering rationale, see [`references/_sections.md`](references/_sections.md).

## Rule Categories

| # | Category | Prefix | Move | Rules |
|---|----------|--------|------|-------|
| 1 | Find | `find` | Locate the right code given the query; bounded read of knowledge | 4 |
| 2 | Trace | `trace` | Follow imports and usages to map the pattern | 2 |
| 3 | Filter | `filter` | Cut noise to surface load-bearing pattern | 1 |
| 4 | Capture | `capture` | Write code topography to registry/ for reuse | 1 |

## Quick Reference

### 1. Find

- [`find-classify-query`](references/find-classify-query.md) — Classify the query (component / composition / state / effect / error / build / routing) before grepping; the classification picks the grep targets and folder hints
- [`find-grep-before-read`](references/find-grep-before-read.md) — Grep narrowly first to pinpoint files; never start by reading whole files
- [`find-tests-show-intent`](references/find-tests-show-intent.md) — Tests, `examples/`, and `e2e/` dirs are the authors' canonical demonstration of intent; consult them before forming a hypothesis from prose
- [`find-bounded-knowledge-read`](references/find-bounded-knowledge-read.md) — Filename is the index: read only `knowledge/libraries/<slug>.md`, never scan the dir; bounds per-invocation token cost regardless of knowledge-store size

### 2. Trace

- [`trace-imports-outward`](references/trace-imports-outward.md) — From the implementation file, follow imports outward to discover the pattern's public surface and dependencies
- [`trace-usages-inward`](references/trace-usages-inward.md) — From the public surface, find call sites inside the same repo to see variants, edge cases, and how the pattern evolves

### 3. Filter

- [`filter-load-bearing`](references/filter-load-bearing.md) — Cut boilerplate (re-exports, builders, helpers), legacy paths (deprecated dirs, `_old/`, `legacy/`), and test scaffolding from the answer; only the load-bearing pattern is the answer

### 4. Capture

- [`capture-registry-record`](references/capture-registry-record.md) — At end of a successful session, write the `code:` section of `knowledge/libraries/<library>.md` (repo URL, branch, SHA, folder map, naming conventions, AGENTS.md flag, samples-dir location) so the next lookup skips discovery

## Knowledge Store

Per-library code topography records live in the repo-root shared knowledge graph at [`/knowledge/libraries/`](../../../knowledge/libraries/). The same files are written by [`docs-search`](../docs-search/SKILL.md) — each skill owns one section (`code:` for this skill, `docs:` for `docs-search`) and never overwrites the other. See [`knowledge/README.md`](../../../knowledge/README.md) for the merged schema, wiki-link conventions, and the merge discipline.

The knowledge store is **intentionally empty at v0.1.0**. The radical-simplification recommendation that produced this skill said: do not pre-empt; add the first entry from a real lookup. If you find yourself adding a record for a repo you have not actually queried, stop — wait for the real need.

**Read discipline**: when the user names a library, do exactly `read knowledge/libraries/<slug>.md`. Never scan `knowledge/libraries/` to "see what's available" — the filename is the index, and lazy access is what keeps per-invocation token cost bounded regardless of knowledge-store size.

## Related Skills

- [`docs-search`](../docs-search/SKILL.md) — Symmetric sibling for **documentation** instead of source code; same shape (methodology + shared knowledge graph); writes the `docs:` section of the same `knowledge/libraries/<lib>.md` files this skill writes the `code:` section of
- [`library-reference-distillation`](../library-reference-distillation/SKILL.md) — Authoring playbook for full library-ref rule packs from upstream docs; the heavy docs-source sibling
- (Future) **code-atlas-distillation** — Not yet built. Authoring playbook for full static code-atlas skills like `opencode-ts`. Extract when you ship your 4th or 5th static code-atlas skill and the empirical patterns are observable.
- [`opencode-ts`](../opencode-ts/SKILL.md), [`openai-codex-rust-patterns`](../openai-codex-rust-patterns/SKILL.md), [`nextjs-ppr-patterns`](../nextjs-ppr-patterns/SKILL.md) — Heavy curated outputs for specific libraries; use them in preference to this skill when they exist
- [`codebase-comprehension-algorithms`](../codebase-comprehension-algorithms/SKILL.md) — Heavy algorithmic toolkit (Leiden, MoJoFM, SBM) for full-codebase domain mapping; orthogonal to focused-query extraction
- [`radical-simplification`](../radical-simplification/SKILL.md) — Thinking layer above this skill; this skill itself is the third instance of the "constrain → name the invariant" move applied to the recurring "N skills per X" trap

## Authoring Note

These rules are **load-bearing**, not decorative. Each names a wrong default an agent has when reaching for unfamiliar source code: reading whole files before grepping, ignoring tests as canonical intent, conflating boilerplate with load-bearing pattern, treating each lookup as one-shot. If a rule restates something a capable model already does correctly, cut it. Coverage is proven by `/dev-skill:eval` on real "how does X implement Y" prompts, not by rule count. The registry grows organically as real lookups demand entries; when a library gets queried more than ~3 times, that is the signal to graduate it to a full static code-atlas skill.
