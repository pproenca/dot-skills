# Feature Specification and Planning Best Practices

Feature specification and planning guidelines for software engineers, product managers, and technical leads. This skill provides a comprehensive framework for writing clear specifications, preventing scope creep, and managing requirements effectively.

## Overview

This skill contains 42 rules across 8 categories, covering the complete feature planning lifecycle from scope definition to documentation.

### Directory Structure

```
feature-spec-planning/
├── SKILL.md              # Entry point with quick reference
├── AGENTS.md             # Compiled comprehensive guide
├── metadata.json         # Version, organization, references
├── README.md             # This file
└── rules/
    ├── _sections.md      # Category definitions
    ├── scope-*.md        # Scope definition rules
    ├── req-*.md          # Requirements clarity rules
    ├── prio-*.md         # Prioritization framework rules
    ├── accept-*.md       # Acceptance criteria rules
    ├── stake-*.md        # Stakeholder alignment rules
    ├── tech-*.md         # Technical specification rules
    ├── change-*.md       # Change management rules
    └── doc-*.md          # Documentation standards rules
```

## Getting Started

### Installation

```bash
pnpm install
```

### Building

```bash
pnpm build
```

### Validation

```bash
pnpm validate
```

## Creating a New Rule

1. Determine the appropriate category and prefix
2. Create a new file in `rules/` following the naming convention
3. Use the rule template structure
4. Run validation to check compliance

### Category Prefixes

| Category | Prefix | Impact |
|----------|--------|--------|
| Scope Definition | `scope-` | CRITICAL |
| Requirements Clarity | `req-` | CRITICAL |
| Prioritization Frameworks | `prio-` | HIGH |
| Acceptance Criteria | `accept-` | HIGH |
| Stakeholder Alignment | `stake-` | MEDIUM-HIGH |
| Technical Specification | `tech-` | MEDIUM |
| Change Management | `change-` | MEDIUM |
| Documentation Standards | `doc-` | LOW |

## Rule File Structure

Each rule file should follow this template:

```markdown
---
title: Rule Title
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: Quantified impact description
tags: prefix, technique, related-concepts
---

## Rule Title

Brief explanation of WHY this matters (1-3 sentences).

**Incorrect (what's wrong):**

\`\`\`language
// Bad code example
\`\`\`

**Correct (what's right):**

\`\`\`language
// Good code example
\`\`\`

Reference: [Reference Title](URL)
```

## File Naming Convention

Rule files follow the pattern: `{prefix}-{description}.md`

Examples:
- `scope-define-boundaries.md`
- `req-user-stories.md`
- `change-formal-process.md`

## Impact Levels

| Level | Description |
|-------|-------------|
| CRITICAL | Rules that prevent major project failures |
| HIGH | Rules that significantly improve project outcomes |
| MEDIUM-HIGH | Rules that reduce friction and late-stage changes |
| MEDIUM | Rules that improve quality and change control |
| LOW-MEDIUM | Rules for specific scenarios |
| LOW | Best practices for long-term knowledge preservation |

## Scripts

- `pnpm validate` - Validate all rules against guidelines
- `pnpm build` - Compile rules into AGENTS.md
- `pnpm lint` - Check markdown formatting

## Contributing

1. Read the existing rules to understand the style and format
2. Ensure your rule has both incorrect and correct examples
3. Include a quantified impact description
4. Reference authoritative sources
5. Run validation before submitting

## References

- [Wrike - What is Scope Creep](https://www.wrike.com/project-management-guide/faq/what-is-scope-creep-in-project-management/)
- [Atlassian - Product Requirements](https://www.atlassian.com/agile/product-management/requirements)
- [SAFe - User Stories](https://www.scaledagileframework.com/user-stories/)
- [ProductPlan - RICE Scoring](https://www.productplan.com/glossary/rice-scoring-model/)
- [ADR GitHub](https://adr.github.io/)
- [Google SRE - Service Level Objectives](https://sre.google/sre-book/service-level-objectives/)

## Acknowledgments

This skill draws on feature planning best practices from product management methodologies, agile frameworks, and established specification techniques including MoSCoW prioritization, RICE scoring, and Architecture Decision Records.
