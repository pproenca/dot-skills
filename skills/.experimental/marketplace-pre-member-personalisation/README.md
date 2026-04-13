# Marketplace Pre-Member Personalisation Skill

Research-grounded best-practices skill for the pre-member journey of a two-sided trust
marketplace — from anonymous landing through onboarding, registration, and the paid-
membership paywall.

## Overview

This skill is a distillation of published consumer-trust and decision research applied
to the specific problem of converting anonymous visitors into paid members of a two-
sided trust marketplace. It contains 53 rules across 10 categories, every rule cited
back to primary research (Cialdini, Kahneman, Roth, Fogg, Bandura, Slovic, Nielsen
Norman Group) or to production engineering literature (Airbnb, DoorDash).

The skill is the precursor to `marketplace-personalisation` and
`marketplace-search-recsys-planning` — it handles everything before the paid-member
boundary, and explicitly hands off to those skills at the moment of conversion.

## Structure

```
marketplace-pre-member-personalisation/
├── SKILL.md                    # Entry point, category index, research foundations
├── AGENTS.md                   # Compiled navigation (built by script)
├── metadata.json               # Version, discipline, research references
├── README.md                   # This file
├── gotchas.md                  # Living diagnostic lessons
├── references/
│   ├── _sections.md            # Category definitions and cascade rationale
│   ├── signal-*.md             # Anonymous Signal Inference (6 rules)
│   ├── owner-*.md              # Pet Owner Validation and Trust (6 rules)
│   ├── sitter-*.md             # Pet Sitter Validation and Opportunity (6 rules)
│   ├── gap-*.md                # Information-Asymmetry Closure (6 rules)
│   ├── profile-*.md            # Progressive Profile Building (5 rules)
│   ├── proof-*.md              # Social Proof and Lookalike Cohorts (5 rules)
│   ├── convert-*.md            # Personalised Conversion Triggers (5 rules)
│   ├── onboard-*.md            # Onboarding Intent Capture (5 rules)
│   ├── stitch-*.md             # Identity Stitching (5 rules)
│   └── measure-*.md            # Pre-Member Measurement and Experimentation (4 rules)
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
node scripts/validate-skill.js skills/.experimental/marketplace-pre-member-personalisation
```

Build the compiled navigation document:

```
node scripts/build-agents-md.js skills/.experimental/marketplace-pre-member-personalisation
```

## Creating a New Rule

Rules go in `references/` with a filename of the form `{prefix}-{slug}.md`, where
`{prefix}` matches an existing category in `references/_sections.md`. Copy
`assets/templates/_template.md` as a starting point and fill in frontmatter and body.

A rule must include:

- YAML frontmatter: `title`, `impact`, `impactDescription`, `tags` (first tag is the prefix)
- One-to-three sentence explanation of why the rule matters, grounded in primary research where possible
- An `**Incorrect (specific description):**` code block with production-realistic code
- A `**Correct (specific description):**` code block that differs minimally from the incorrect
- A `Reference:` line linking to a research paper, book, or production engineering blog

Run `pnpm validate` after adding or editing rules.

## Rule File Structure

Each rule has a strict structure enforced by the validator:

```markdown
---
title: Show Specific Local Owner Reviews, Not Global Averages
impact: CRITICAL
impactDescription: enables identifiable-victim social proof
tags: owner, social-proof, reviews
---

## Show Specific Local Owner Reviews, Not Global Averages

Explanation paragraph — why the rule matters, what research supports it,
and how it closes a specific objection a visitor has before paying.

**Incorrect (concrete failure mode):**

\`\`\`typescript
// Production-realistic bad example
\`\`\`

**Correct (concrete solution):**

\`\`\`typescript
// Production-realistic good example
\`\`\`

Reference: [Primary Research Source](https://example.com/paper)
```

## File Naming Convention

- Skill directory: kebab-case matching the skill name (`marketplace-pre-member-personalisation`)
- Rule files: `{category-prefix}-{slug}.md` with kebab-case slugs
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

Target distribution for a 40-60 rule distillation: 1-2 CRITICAL categories, 2-3 HIGH,
the rest MEDIUM or lower. This skill has 2 CRITICAL, 2 HIGH, 3 MEDIUM-HIGH and 3 MEDIUM
categories.

## Scripts

The dev-skill plugin provides two scripts used by this skill:

- `scripts/validate-skill.js` — runs structural and substance validation (required before shipping)
- `scripts/build-agents-md.js` — compiles the navigation document (never write AGENTS.md manually)

Example invocations:

```
node scripts/validate-skill.js skills/.experimental/marketplace-pre-member-personalisation
node scripts/validate-skill.js skills/.experimental/marketplace-pre-member-personalisation --sections-only
node scripts/build-agents-md.js skills/.experimental/marketplace-pre-member-personalisation
```

## Contributing

- New rules must follow the structure above and pass `pnpm validate` with zero errors
- Every rule must have incorrect and correct examples with specific annotations
- Every rule must cite primary research (peer-reviewed paper, foundational book, or production engineering blog with data)
- Avoid hedging language (`might`, `perhaps`, `it is recommended`) — use imperative form
- Quantify impact where possible or use pattern verbs (`enables`, `prevents`, `reduces`)
- Update `gotchas.md` when a new diagnostic lesson is learned
- Never edit `AGENTS.md` manually — it is regenerated by `build-agents-md.js`
