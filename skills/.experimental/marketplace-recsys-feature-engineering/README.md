# Marketplace Recsys Feature Engineering Skill

First-principles best-practices skill for deriving usable recommender features
from the raw assets of a two-sided trust marketplace — listing photos,
owner-entered listing metadata, and sitter wizard responses — for
item-to-item, user-to-item, and user-to-user solutions.

## Overview

This skill is a distillation of authoritative guidance from engineering blogs
at Airbnb, Pinterest, DoorDash, Uber, and Netflix, open-source libraries
(Feast, Sentence-Transformers, Hugging Face CLIP, H3), foundational academic
papers (Airbnb KDD 2018, Pinterest ItemSage, YouTube Semantic IDs, PinSage),
and Google's Rules of Machine Learning. It contains 44 rules across 8
categories, ordered by cascade impact on the feature-engineering lifecycle,
and one playbook that composes the rules into an end-to-end feature discovery
workflow.

This skill is the **upstream precursor** to the sibling
`marketplace-personalisation`, `marketplace-search-recsys-planning`, and
`marketplace-pre-member-personalisation` skills. Use it when the question is
"what features should we build?"; hand off to the others when the question
becomes "how do we rank, retrieve, or convert?"

## Structure

```
marketplace-recsys-feature-engineering/
├── SKILL.md                    # Entry point with category index and quick reference
├── AGENTS.md                   # Compiled navigation document (built by script)
├── metadata.json               # Version, discipline, authoritative references
├── README.md                   # This file
├── gotchas.md                  # Accumulated diagnostic lessons (living)
├── references/
│   ├── _sections.md            # Category definitions and impact ordering
│   ├── audit-*.md              # Asset Audit and Inventory (5 rules)
│   ├── firstp-*.md             # First-Principles Feature Decomposition (6 rules)
│   ├── vision-*.md             # Image Feature Extraction (6 rules)
│   ├── listing-*.md            # Listing Text and Metadata Extraction (6 rules)
│   ├── wizard-*.md             # Sitter Wizard and Profile Extraction (5 rules)
│   ├── derive-*.md             # Derived Similarity and Affinity (6 rules)
│   ├── quality-*.md            # Feature Quality and Governance (5 rules)
│   ├── prove-*.md              # Incremental Rollout and Value Proof (5 rules)
│   └── playbooks/
│       └── discovering.md      # End-to-end feature discovery workflow
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
node scripts/validate-skill.js skills/.experimental/marketplace-recsys-feature-engineering
```

Build the compiled navigation document:

```
node scripts/build-agents-md.js skills/.experimental/marketplace-recsys-feature-engineering
```

## Creating a New Rule

Rules go in `references/` with a filename of the form `{prefix}-{slug}.md`,
where `{prefix}` matches an existing category in `references/_sections.md`.
Copy `assets/templates/_template.md` as a starting point and fill in the
frontmatter and body.

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
title: Use Two-Tower for User-to-Item Affinity
impact: MEDIUM-HIGH
impactDescription: 2-5x NDCG over hand-crafted scoring
tags: derive, u2i, two-tower, dual-encoder
---

## Use Two-Tower for User-to-Item Affinity

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

- Skill directory: kebab-case matching the skill name (`marketplace-recsys-feature-engineering`)
- Rule files: `{category-prefix}-{slug}.md` with kebab-case slugs (`audit-measure-coverage-before-modelling.md`)
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

Target distribution for a 40-60 rule distillation: 2-3 CRITICAL categories,
2-4 HIGH, the rest MEDIUM or lower. This skill has 2 CRITICAL, 3 HIGH, 2
MEDIUM-HIGH, and 1 MEDIUM category.

## Scripts

The dev-skill plugin provides two scripts used by this skill:

- `scripts/validate-skill.js` — runs structural and substance validation (required before shipping)
- `scripts/build-agents-md.js` — compiles the navigation document (never write AGENTS.md manually)

Example invocations:

```
node scripts/validate-skill.js skills/.experimental/marketplace-recsys-feature-engineering
node scripts/validate-skill.js skills/.experimental/marketplace-recsys-feature-engineering --sections-only
node scripts/build-agents-md.js skills/.experimental/marketplace-recsys-feature-engineering
```

## Contributing

- New rules must follow the structure above and pass `pnpm validate` with zero errors
- Every rule must have incorrect and correct examples with specific annotations
- References must be from primary maintainers, peer-reviewed research, or engineering blogs with data
- Avoid hedging language (`might`, `perhaps`, `it is recommended`) — use imperative form
- Quantify impact where possible (`2-10×`, `200ms`, `prevents stale closures`, `O(n) to O(1)`)
- Playbooks in `references/playbooks/` compose rules into end-to-end workflows
- Never edit `AGENTS.md` manually — it is regenerated by `build-agents-md.js`
