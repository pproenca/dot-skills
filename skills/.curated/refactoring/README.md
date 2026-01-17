# Code Refactoring Best Practices

A comprehensive collection of code refactoring rules based on Martin Fowler's refactoring catalog and Robert C. Martin's Clean Code principles.

## Overview

This skill provides 43 rules across 8 categories to help AI agents and developers refactor code systematically. Rules are prioritized by impact, from critical structural improvements to incremental micro-refactoring.

## Structure

```
code-refactor/
├── SKILL.md              # Entry point with quick reference
├── AGENTS.md             # Compiled comprehensive guide
├── metadata.json         # Version, organization, references
├── README.md             # This file
└── rules/
    ├── _sections.md      # Category definitions
    ├── struct-*.md       # Structure & Decomposition rules (7)
    ├── couple-*.md       # Coupling & Dependencies rules (6)
    ├── name-*.md         # Naming & Clarity rules (5)
    ├── cond-*.md         # Conditional Logic rules (6)
    ├── pattern-*.md      # Abstraction & Patterns rules (6)
    ├── data-*.md         # Data Organization rules (5)
    ├── error-*.md        # Error Handling rules (4)
    └── micro-*.md        # Micro-Refactoring rules (4)
```

## Getting Started

```bash
# Install dependencies (if using validation scripts)
pnpm install

# Build AGENTS.md from individual rules
pnpm build

# Validate the skill against quality guidelines
pnpm validate
```

## Creating a New Rule

1. Determine the category based on the rule's primary focus
2. Use the appropriate prefix from the table below
3. Create a new file: `rules/{prefix}-{descriptive-name}.md`
4. Follow the template in `rules/_template.md`

### Prefix Reference

| Category | Prefix | Impact |
|----------|--------|--------|
| Structure & Decomposition | `struct-` | CRITICAL |
| Coupling & Dependencies | `couple-` | CRITICAL |
| Naming & Clarity | `name-` | HIGH |
| Conditional Logic | `cond-` | HIGH |
| Abstraction & Patterns | `pattern-` | MEDIUM-HIGH |
| Data Organization | `data-` | MEDIUM |
| Error Handling | `error-` | MEDIUM |
| Micro-Refactoring | `micro-` | LOW |

## Rule File Structure

Each rule file follows this structure:

```markdown
---
title: Rule Title
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: Quantified impact (e.g., "reduces complexity by 50%")
tags: prefix, keyword1, keyword2
---

## Rule Title

Brief explanation of WHY this matters (1-3 sentences).

**Incorrect (what's wrong):**

\`\`\`typescript
// Bad code example with comment explaining the cost
\`\`\`

**Correct (what's right):**

\`\`\`typescript
// Good code example with comment explaining the benefit
\`\`\`

**When NOT to use:**
- Exception 1
- Exception 2

Reference: [Reference Title](URL)
```

## File Naming Convention

Rule files follow the pattern: `{prefix}-{descriptive-slug}.md`

- **prefix**: Category identifier (3-8 characters)
- **slug**: Kebab-case description of the rule

Examples:
- `struct-extract-method.md`
- `cond-guard-clauses.md`
- `pattern-strategy.md`

## Impact Levels

| Level | Description |
|-------|-------------|
| CRITICAL | Foundational improvements with cascade effects |
| HIGH | Significant improvements to readability or maintainability |
| MEDIUM-HIGH | Important patterns that enable extensibility |
| MEDIUM | Valuable improvements with localized impact |
| LOW-MEDIUM | Minor improvements with cumulative benefits |
| LOW | Small improvements, apply incrementally |

## Scripts

| Command | Description |
|---------|-------------|
| `pnpm build` | Compile rules into AGENTS.md |
| `pnpm validate` | Validate skill against quality checklist |
| `pnpm lint` | Check markdown formatting |

## Contributing

1. Read the existing rules to understand the style
2. Follow the rule file template exactly
3. Include both incorrect and correct code examples
4. Quantify impact where possible
5. Reference authoritative sources
6. Run validation before submitting

## Acknowledgments

This skill is based on:
- [Refactoring: Improving the Design of Existing Code](https://martinfowler.com/books/refactoring.html) by Martin Fowler
- [Clean Code](https://www.oreilly.com/library/view/clean-code-a/9780136083238/) by Robert C. Martin
- [Refactoring Catalog](https://refactoring.com/catalog/)
- [Refactoring Guru](https://refactoring.guru/)
