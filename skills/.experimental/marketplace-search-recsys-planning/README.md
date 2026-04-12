# Marketplace Search and Recsys Planning Skill

Planning, design and diagnostic best-practices skill for search and recommendation systems
in two-sided trust marketplaces built on OpenSearch. Functions as the precursor to the
companion `marketplace-personalisation` skill.

## Overview

This skill is a distillation of authoritative guidance from OpenSearch documentation,
canonical search-relevance engineering texts (Turnbull's *Relevant Search*), academic
work on two-sided marketplace recommendation, Google's Rules of Machine Learning, and
production engineering blogs from two-sided marketplace companies. It contains 57 rules
across 10 categories, ordered by cascade impact on the retrieval lifecycle, plus two
playbooks and explicit living-artefact conventions for evolving context.

The skill treats the marketplace system as an evolving artefact — a gotchas log, a
decisions log, and a versioned golden set carry context across sessions, releases, and
team changes.

## Structure

```
marketplace-search-recsys-planning/
├── SKILL.md                    # Entry point with category index and quick reference
├── AGENTS.md                   # Compiled navigation document (built by script)
├── metadata.json               # Version, discipline, authoritative references
├── README.md                   # This file
├── gotchas.md                  # Living diagnostic lessons (append-only)
├── references/
│   ├── _sections.md            # Category definitions and impact ordering
│   ├── intent-*.md             # Problem Framing and User Intent (6 rules)
│   ├── arch-*.md               # Surface Taxonomy and Architecture (6 rules)
│   ├── index-*.md              # Index Design and Mapping (7 rules)
│   ├── plan-*.md               # Planning and Improvement Methodology (6 rules)
│   ├── query-*.md              # Query Understanding (6 rules)
│   ├── retrieve-*.md           # Retrieval Strategy (6 rules)
│   ├── rank-*.md               # Relevance and Ranking (5 rules)
│   ├── blend-*.md              # Search and Recommender Blending (4 rules)
│   ├── measure-*.md            # Measurement and Experimentation (5 rules)
│   ├── monitor-*.md            # Instrumentation, Dashboards and Decision Triggers (6 rules)
│   └── playbooks/
│       ├── planning.md         # Plan a new retrieval system from scratch
│       └── improving.md        # Diagnose and improve an existing one
└── assets/
    └── templates/
        └── _template.md        # Template for authoring new rules
```

## Getting Started

From the repo root, install plugin dependencies and run the skill validator:

```
pnpm install
pnpm build
pnpm validate
```

The validator runs structural and substance checks against the skill:

```
node scripts/validate-skill.js skills/.experimental/marketplace-search-recsys-planning
```

Build the compiled navigation document:

```
node scripts/build-agents-md.js skills/.experimental/marketplace-search-recsys-planning
```

## Creating a New Rule

Rules go in `references/` with a filename of the form `{prefix}-{slug}.md`, where `{prefix}`
matches an existing category in `references/_sections.md`. Copy `assets/templates/_template.md`
as a starting point and fill in the frontmatter and body.

A rule must include:

- YAML frontmatter: `title`, `impact`, `impactDescription`, `tags` (first tag is the prefix)
- One-to-three sentence explanation of why the rule matters and its cascade effect
- An `**Incorrect (specific description):**` code block with production-realistic code
- A `**Correct (specific description):**` code block that differs minimally from the incorrect
- A `Reference:` line linking to an authoritative source (OpenSearch docs, canonical text, or engineering blog)

Run `pnpm validate` after adding or editing rules.

## Rule File Structure

Each rule has a strict structure enforced by the validator:

```markdown
---
title: Use Filter Clauses for Exact Matches
impact: MEDIUM-HIGH
impactDescription: enables query result caching
tags: retrieve, filter, caching
---

## Use Filter Clauses for Exact Matches

Explanation paragraph — why the rule matters, what goes wrong without it,
and how the cascade effect plays out downstream.

**Incorrect (concrete failure mode):**

```json
{ "production-realistic bad example": "here" }
```

**Correct (concrete solution):**

```json
{ "production-realistic good example": "here" }
```

Reference: [OpenSearch Documentation — Query and Filter Context](https://docs.opensearch.org/latest/query-dsl/query-filter-context/)
```

## File Naming Convention

- Skill directory: kebab-case matching the skill name (`marketplace-search-recsys-planning`)
- Rule files: `{category-prefix}-{slug}.md` with kebab-case slugs (`intent-map-queries-to-intent-classes.md`)
- Playbook files: `references/playbooks/{name}.md`
- Templates: `assets/templates/_template.md` (underscore prefix excludes from rule listings)
- Category prefixes are 3-8 lowercase letters and defined once in `_sections.md`

## Impact Levels

Categories and rules use six impact levels ordered from highest to lowest cascade impact:

| Level | Meaning | Cascade Effect |
|-------|---------|----------------|
| `CRITICAL` | Affects every downstream stage | Everything waits on this |
| `HIGH` | Affects most downstream stages | Major path is blocked |
| `MEDIUM-HIGH` | Affects specific downstream paths | Partial blocking |
| `MEDIUM` | Local impact with high frequency | Common but contained |
| `LOW-MEDIUM` | Micro-impact in hot paths | Measurable in loops |
| `LOW` | Edge cases and expert patterns | Specific scenarios only |

Target distribution for a 40-60 rule distillation: 2-3 CRITICAL categories, 2-4 HIGH,
the rest MEDIUM or lower. This skill has 2 CRITICAL, 2 HIGH, 3 MEDIUM-HIGH and 3 MEDIUM
categories with an evenly spread four-tier rule distribution.

## Scripts

The dev-skill plugin provides two scripts used by this skill:

- `scripts/validate-skill.js` — runs structural and substance validation (required before shipping)
- `scripts/build-agents-md.js` — compiles the navigation document (never write AGENTS.md manually)

Example invocations:

```
node scripts/validate-skill.js skills/.experimental/marketplace-search-recsys-planning
node scripts/validate-skill.js skills/.experimental/marketplace-search-recsys-planning --sections-only
node scripts/build-agents-md.js skills/.experimental/marketplace-search-recsys-planning
```

## Contributing

- New rules must follow the structure above and pass `pnpm validate` with zero errors
- Every rule must have incorrect and correct examples with specific annotations
- References must be from OpenSearch maintainers, canonical search texts, peer-reviewed research, or engineering blogs with data
- Avoid hedging language (`might`, `perhaps`, `it is recommended`) — use imperative form
- Quantify impact where possible (`10-15%`, `200ms`, `prevents stale closures`, `O(n) to O(1)`)
- Playbooks in `references/playbooks/` compose rules into end-to-end workflows
- Update `gotchas.md` when a new diagnostic lesson is learned
- Never edit `AGENTS.md` manually — it is regenerated by `build-agents-md.js`
