# Algorithmic Complexity Review

Language-agnostic Big-O review skill for AI agents. Helps find, classify, and fix algorithmic complexity issues in code — nested iteration, N+1 I/O, data-structure mismatch, recursion blowups, redundant computation, collection-building anti-patterns, search/sort selection, and space traps.

## Overview

This skill is a **distillation / code-quality** Agent Skill. The agent's entry point is [`SKILL.md`](SKILL.md); the bulk of the content lives in `references/` as 39 individually-loadable rule files organized by category prefix. The TOC navigation document [`AGENTS.md`](AGENTS.md) is auto-generated.

### Structure

| Path | What |
|------|------|
| [`SKILL.md`](SKILL.md) | Entry point loaded when the skill triggers |
| [`AGENTS.md`](AGENTS.md) | Auto-generated TOC navigation |
| [`metadata.json`](metadata.json) | Discipline, type, and authoritative source URLs |
| [`references/_sections.md`](references/_sections.md) | Category definitions, impact levels, ordering rationale |
| `references/{prefix}-*.md` | 39 individual rules across 8 categories |
| [`assets/templates/_template.md`](assets/templates/_template.md) | Template for adding new rules |

## Getting Started

The skill is plain Markdown + JSON — no build step or runtime is needed to use it. The commands below operate on the parent `dot-skills` repo and the dev-skill plugin toolchain.

```bash
# In the parent dot-skills repo (one-time, if pnpm is the package manager)
pnpm install
pnpm build
pnpm validate

# Validate this skill specifically (preferred for iteration)
node {dev-skill-plugin}/scripts/validate-skill.js \
  skills/.experimental/algorithmic-complexity-review

# Rebuild the TOC after adding or editing rules
node {dev-skill-plugin}/scripts/build-agents-md.js \
  skills/.experimental/algorithmic-complexity-review
```

The skill is auto-loaded by Claude Code when its trigger description matches the user's intent. No installation step is required beyond having the skill present under `skills/`.

## Creating a New Rule

1. Pick a category prefix from [`references/_sections.md`](references/_sections.md). The first tag in the rule frontmatter must match this prefix.
2. Copy [`assets/templates/_template.md`](assets/templates/_template.md) into `references/{prefix}-{slug}.md`.
3. Fill in the frontmatter (`title`, `impact`, `impactDescription`, `tags`), the WHY explanation, and the **Incorrect** / **Correct** code examples.
4. Add a "When NOT to use" section if the rule has non-trivial exceptions.
5. Cite an authoritative source at the bottom (Python TimeComplexity, MDN, NIST DADS, cppreference, V8 blog, CLRS, Sedgewick — see [`metadata.json`](metadata.json) for the canonical list).
6. Rebuild `AGENTS.md` and validate (see [Scripts](#scripts) below).

## Rule File Structure

Every rule file under `references/` follows this layout:

```markdown
---
title: {Action-Oriented Title}
impact: CRITICAL | HIGH | MEDIUM-HIGH | MEDIUM | LOW-MEDIUM | LOW
impactDescription: {Quantified impact, e.g., "O(n²) to O(n) — 100× at n=10,000"}
tags: {prefix}, {technique}, {tool-or-concept}
---

## {Title}

{1-3 sentences explaining WHY the anti-pattern matters — the cascade effect,
what scales wrong, why it hides at the call site.}

**Incorrect ({short label}):**

```{language}
{Production-realistic bad code with cost annotations}
```

**Correct ({short label}):**

```{language}
{Minimal-diff fix with benefit annotations}
```

**When NOT to use this pattern:**

- {Specific exception}

Reference: [{Title}]({URL})
```

The "Incorrect" example must be production-realistic (no strawman); the "Correct" example must be a minimal diff so the agent can see exactly which lines change.

## File Naming Convention

| Element | Convention | Example |
|---------|------------|---------|
| Rule file | `{prefix}-{slug}.md` (kebab-case) | `nested-includes-in-loop.md` |
| Prefix | 3-8 chars, defined in `_sections.md` | `nested-`, `rec-`, `space-` |
| Slug | kebab-case, describes the action | `memoize-overlapping-subproblems` |
| First tag | MUST equal the prefix (no hyphen) | `tags: nested, ...` |

Filenames must not collide across categories. Each prefix maps to exactly one category in `_sections.md`.

## Impact Levels

Categories and individual rules are ordered by **cascade severity** (how much downstream work the anti-pattern blocks) × **frequency** in real code.

| Level | Criteria | Example |
|-------|----------|---------|
| CRITICAL | Affects ALL downstream operations; quadratic or worse | Nested `.includes()` in a loop |
| HIGH | Affects MOST downstream operations | Wrong data structure for access pattern |
| MEDIUM-HIGH | Affects specific downstream paths | Loop-invariant computation |
| MEDIUM | Local impact, common pattern | Re-sorting in a loop |
| LOW-MEDIUM | Micro-optimization, hot paths | Pre-sizing collections |
| LOW | Edge cases, expert patterns | Rare allocation patterns |

The 39 rules in this skill break down as:

| Category | Prefix | Impact | Rules |
|----------|--------|--------|-------|
| Nested Iteration Patterns | `nested-` | CRITICAL | 6 |
| Loop-Invariant I/O and N+1 | `io-` | CRITICAL | 5 |
| Data Structure Mismatch | `ds-` | HIGH | 6 |
| Recursion Complexity | `rec-` | HIGH | 5 |
| Redundant Computation | `compute-` | MEDIUM-HIGH | 5 |
| Collection Building | `build-` | MEDIUM | 4 |
| Search & Sort Selection | `search-` | MEDIUM | 4 |
| Space Complexity Traps | `space-` | LOW-MEDIUM | 4 |

## Scripts

All scripts live in the dev-skill plugin toolchain, not in this skill. Replace `{plugin}` below with the active dev-skill plugin path (typically `~/.claude/plugins/cache/dot-claude/dev-skill/{version}`).

| Script | Purpose |
|--------|---------|
| `{plugin}/scripts/validate-skill.js` | Structural + substance validation (frontmatter, sections, references, code examples) |
| `{plugin}/scripts/build-agents-md.js` | Regenerates `AGENTS.md` TOC from `_sections.md` + rule frontmatter |
| `{plugin}/scripts/eval/quick_validate.py` | Fast frontmatter sanity check (Python) |
| `{plugin}/scripts/eval/run_eval.py` | Functional trigger evaluation against a prompt set |

Common invocations:

```bash
# Full validation
node {plugin}/scripts/validate-skill.js skills/.experimental/algorithmic-complexity-review

# Strict mode (treat warnings as errors)
node {plugin}/scripts/validate-skill.js skills/.experimental/algorithmic-complexity-review --strict

# Validate only _sections.md (during incremental authoring)
node {plugin}/scripts/validate-skill.js skills/.experimental/algorithmic-complexity-review --sections-only

# Rebuild AGENTS.md after editing rules
node {plugin}/scripts/build-agents-md.js skills/.experimental/algorithmic-complexity-review
```

## Contributing

1. Open an issue describing the algorithmic pattern you want to add or correct, with at least one authoritative source (textbook, official docs, primary maintainer blog) backing the complexity claim.
2. Add the rule file under `references/{prefix}-{slug}.md` following [Rule File Structure](#rule-file-structure).
3. If the rule introduces a new category, add it to `references/_sections.md` first (with a one-sentence cascade-effect description) and run `--sections-only` validation.
4. Rebuild `AGENTS.md`, run full validation in strict mode, and ensure both pass with zero errors and zero warnings.
5. Open a PR. The reviewer will check teaching effectiveness, realism of the code examples, and accuracy of the impact claims against the cited source.

Discipline-aware review uses the rubric at `{plugin}/templates/disciplines/distillation/RUBRIC.md`. Run the `skill-reviewer` agent locally before requesting review.
