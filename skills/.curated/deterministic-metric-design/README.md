# Deterministic Metric Design

A methodology skill for AI agents on inventing rigorous, deterministic software metrics — measures an agent can trust and *optimize against* without gaming them. It covers the full path from a fuzzy construct to an adoptable, machine-checkable number: define the construct, confront computability limits with sound proxies, ground it in measurement theory, prove its properties, pin its determinism, validate it empirically, harden it against optimization pressure, and package it for adoption.

A running example threads through every category — a deterministic measure of **behavior-preserving codebase-size reduction** (shrink code without changing how the app works), whose ideal form is provably out of reach (Kolmogorov complexity is uncomputable; program equivalence is undecidable by Rice's theorem).

This is the measurement-design layer that the `*-algorithms` skills *apply* (Big-O, NDCG, cyclomatic, MoJoFM) but never *teach*.

## Overview

This skill is a **distillation / code-quality** Agent Skill. The agent's entry point is [`SKILL.md`](SKILL.md); the bulk of the content lives in `references/` as 44 individually-loadable rule files organized by category prefix. The TOC navigation document [`AGENTS.md`](AGENTS.md) is auto-generated.

### Structure

| Path | What |
|------|------|
| [`SKILL.md`](SKILL.md) | Entry point loaded when the skill triggers |
| [`AGENTS.md`](AGENTS.md) | Auto-generated TOC navigation |
| [`metadata.json`](metadata.json) | Discipline, type, and authoritative source URLs |
| [`references/_sections.md`](references/_sections.md) | Category definitions, impact levels, ordering rationale |
| `references/{prefix}-*.md` | 44 individual rules across 8 categories |
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
  skills/.experimental/deterministic-metric-design

# Rebuild the TOC after adding or editing rules
node {dev-skill-plugin}/scripts/build-agents-md.js \
  skills/.experimental/deterministic-metric-design
```

The skill is auto-loaded by Claude Code when its trigger description matches the user's intent. No installation step is required beyond having the skill present under `skills/`.

## How to Use the Skill

1. Identify where you are with the **Workflow** table in [`SKILL.md`](SKILL.md) (Define → Make Computable → Prove → Validate → Harden) and open the matching first rule.
2. Work the categories top-down — `def-` and `comp-` are CRITICAL because a fuzzy construct or an uncomputable ideal makes everything downstream noise or unusable.
3. For a new metric, produce a one-page spec naming, one line per category: construct, proxy, scale + unit + zero, proven properties, determinism guarantees, validity evidence, guardrails, and version.
4. When proposing or critiquing a metric, quote the rule by file path so reviewers can check the reasoning.

## Creating a New Rule

1. Pick a category prefix from [`references/_sections.md`](references/_sections.md). The first tag in the rule frontmatter must match this prefix.
2. Copy [`assets/templates/_template.md`](assets/templates/_template.md) into `references/{prefix}-{slug}.md`.
3. Fill in the frontmatter (`title`, `impact`, `impactDescription`, `tags`), the WHY explanation, and the **Incorrect** / **Correct** examples (metric definitions/procedures, not application code).
4. Add a "When NOT to apply" section if the rule has non-trivial exceptions.
5. Cite an authoritative primary source at the bottom (measurement-theory and CS canon — see [`metadata.json`](metadata.json)).
6. Rebuild `AGENTS.md` and validate (see [Scripts](#scripts)).

## Rule File Structure

Every rule file under `references/` follows this layout:

```markdown
---
title: {Action-Oriented Title}
impact: CRITICAL | HIGH | MEDIUM-HIGH | MEDIUM | LOW-MEDIUM | LOW
impactDescription: {what the rule prevents or guarantees, concretely}
tags: {prefix}, {concept}, {concept}
---

## {Title}

{1-3 sentences explaining WHY it matters — what failure (uncomputable, non-deterministic,
invalid, or gameable) it prevents and why that poisons the rest of the metric.}

**Incorrect ({the design flaw}):**

```python
{A realistic, badly-designed metric definition — not a strawman}
```

**Correct ({the fix}):**

```python
{The fixed metric — minimal diff, key insight only}
```

Reference: [{Authoritative source}]({URL})
```

## File Naming Convention

| Element | Convention | Example |
|---------|------------|---------|
| Rule file | `{prefix}-{slug}.md` (kebab-case) | `comp-respect-rices-theorem-for-semantic-properties.md` |
| Prefix | 3-5 chars, defined in `_sections.md` | `def-`, `comp-`, `valid-` |
| Slug | kebab-case, describes the action | `prove-monotonicity` |
| First tag | MUST equal the prefix (no hyphen) | `tags: comp, ...` |

## Impact Levels

Categories and individual rules are ordered by **cascade severity** (how much an upstream mistake poisons everything downstream) × **frequency** in real metric-design work.

| Category | Prefix | Impact | Rules |
|----------|--------|--------|-------|
| Construct Definition & Operationalization | `def-` | CRITICAL | 6 |
| Computability & Tractability | `comp-` | CRITICAL | 7 |
| Measurement-Theoretic Foundations | `meas-` | HIGH | 5 |
| Proof of Metric Properties | `prop-` | HIGH | 6 |
| Determinism & Reproducibility | `det-` | HIGH | 5 |
| Construct Validity & Calibration | `valid-` | MEDIUM-HIGH | 6 |
| Optimization Safety & Anti-Gaming | `game-` | MEDIUM | 5 |
| Aggregation, Reporting & Adoption | `agg-` | LOW-MEDIUM | 4 |

## Scripts

All scripts live in the dev-skill plugin toolchain, not in this skill. Replace `{plugin}` with the active dev-skill plugin path (typically `~/.claude/plugins/cache/dot-claude/dev-skill/{version}`).

| Script | Purpose |
|--------|---------|
| `{plugin}/scripts/validate-skill.js` | Structural + substance validation |
| `{plugin}/scripts/build-agents-md.js` | Regenerates `AGENTS.md` TOC from `_sections.md` + rule frontmatter |

```bash
# Full validation
node {plugin}/scripts/validate-skill.js skills/.experimental/deterministic-metric-design

# Validate only _sections.md (during incremental authoring)
node {plugin}/scripts/validate-skill.js skills/.experimental/deterministic-metric-design --sections-only

# Rebuild AGENTS.md after editing rules
node {plugin}/scripts/build-agents-md.js skills/.experimental/deterministic-metric-design
```

## Related Skills

- `same-results-less-code`, `code-simplifier`, `complexity-optimizer`, `knip-deadcode` — prescriptive code-reduction skills; this skill supplies the measurement layer they lack.
- `algorithmic-complexity-review`, `computer-science-algorithms` — apply existing measures (Big-O); this skill teaches how to design new ones.
- `opensearch-function-scoring-algorithms` — applied ranking metrics; this skill is the foundational methodology beneath its `eval-` category.

## Contributing

1. Open an issue describing the metric-design principle you want to add or correct, with at least one authoritative source (primary paper, standards body, or maintainer docs) backing the claim.
2. Add the rule file under `references/{prefix}-{slug}.md` following [Rule File Structure](#rule-file-structure).
3. If the rule introduces a new category, add it to `references/_sections.md` first (with a one-sentence cascade-effect description) and run `--sections-only` validation.
4. Rebuild `AGENTS.md`, run full validation, and ensure it passes with zero errors.
5. Open a PR. Discipline-aware review uses the rubric at `{plugin}/templates/disciplines/distillation/RUBRIC.md`; run the `skill-reviewer` agent before requesting review. Sources span the measurement-theory and CS canon (Fenton & Bieman, Stevens, Weyuker, Briand–Morasca–Basili, Li & Vitányi, Rice, Cronbach & Meehl, Campbell & Fiske, Manheim & Garrabrant — see [`metadata.json`](metadata.json)).
