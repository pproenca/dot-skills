# Marketplace Personalisation Skill

Best-practices skill for designing, building and improving personalisation and
recommendation systems in two-sided trust marketplaces on AWS Personalize.

## Overview

This skill is a distillation of authoritative guidance from AWS Personalize documentation,
academic research on recommender bias, and production engineering blogs from two-sided
marketplaces. It contains 49 rules across 9 categories, ordered by cascade impact on the
personalisation lifecycle, and two playbooks for end-to-end planning and diagnostic workflows.

## Structure

```
marketplace-personalisation/
├── SKILL.md                    # Entry point with category index and quick reference
├── AGENTS.md                   # Compiled navigation document (built by script)
├── metadata.json               # Version, discipline, authoritative references
├── README.md                   # This file
├── references/
│   ├── _sections.md            # Category definitions and impact ordering
│   ├── track-*.md              # Event Tracking and Capture (6 rules)
│   ├── schema-*.md             # Dataset and Schema Design (7 rules)
│   ├── match-*.md              # Two-Sided Matching Patterns (5 rules)
│   ├── simple-*.md             # Simple Baselines and Theory of Constraints (6 rules)
│   ├── loop-*.md               # Feedback Loops and Bias Control (5 rules)
│   ├── cold-*.md               # Cold Start and Coverage (5 rules)
│   ├── recipe-*.md             # Recipe and Pipeline Selection (5 rules)
│   ├── infer-*.md              # Inference, Filters and Re-ranking (5 rules)
│   ├── obs-*.md                # Observability and Online Metrics (5 rules)
│   └── playbooks/
│       ├── planning.md         # Plan a new recommender from scratch
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
node scripts/validate-skill.js skills/.experimental/marketplace-personalisation
```

Build the compiled navigation document:

```
node scripts/build-agents-md.js skills/.experimental/marketplace-personalisation
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
- A `Reference:` line linking to an authoritative source

Run `pnpm validate` after adding or editing rules.

## Rule File Structure

Each rule has a strict structure enforced by the validator:

```markdown
---
title: Use Exposure Caps Across Providers
impact: HIGH
impactDescription: prevents supply monopolisation
tags: match, fairness, exposure-cap
---

## Use Exposure Caps Across Providers

Explanation paragraph — why the rule matters, what goes wrong without it,
and how the cascade effect plays out downstream.

**Incorrect (concrete failure mode):**

```python
# Production-realistic bad example
```

**Correct (concrete solution):**

```python
# Production-realistic good example
```

Reference: [Source Title](https://example.com/source)
```

## File Naming Convention

- Skill directory: kebab-case matching the skill name (`marketplace-personalisation`)
- Rule files: `{category-prefix}-{slug}.md` with kebab-case slugs (`match-rank-mutual-fit.md`)
- Playbook files: `references/playbooks/{name}.md`
- Templates: `assets/templates/_template.md` (underscore prefix to exclude from rule listings)
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
the rest MEDIUM or lower. This skill has 3 CRITICAL, 3 HIGH and 3 MEDIUM-HIGH categories.

## Scripts

The dev-skill plugin provides two scripts used by this skill:

- `scripts/validate-skill.js` — runs structural and substance validation (required before shipping)
- `scripts/build-agents-md.js` — compiles the navigation document (never write AGENTS.md manually)

Example invocations:

```
node scripts/validate-skill.js skills/.experimental/marketplace-personalisation
node scripts/validate-skill.js skills/.experimental/marketplace-personalisation --sections-only
node scripts/build-agents-md.js skills/.experimental/marketplace-personalisation
```

## Contributing

- New rules must follow the structure above and pass `pnpm validate` with zero errors
- Every rule must have incorrect and correct examples with specific annotations
- References must be from primary maintainers, peer-reviewed research, or engineering blogs with data
- Avoid hedging language (`might`, `perhaps`, `it is recommended`) — use imperative form
- Quantify impact where possible (`2-10×`, `200ms`, `prevents stale closures`, `O(n) to O(1)`)
- Playbooks in `references/playbooks/` compose rules into end-to-end workflows
- Never edit `AGENTS.md` manually — it is regenerated by `build-agents-md.js`
