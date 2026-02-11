# React Refactor Best Practices

Architectural refactoring guide for React applications, designed for AI agents and LLMs.

## Overview

This skill provides 47 rules across 8 categories to guide React architectural refactoring. Each rule includes code smell indicators, before/after transforms, and safe refactoring steps. Covers component architecture, state management, hook design, decomposition, modern React migration, and testing strategies.

## Structure

```
react-refactor/
├── SKILL.md              # Entry point with quick reference
├── AGENTS.md             # Compiled comprehensive guide
├── metadata.json         # Version, references, metadata
├── README.md             # This file
├── references/
│   ├── _sections.md      # Category definitions
│   ├── arch-*.md         # Component architecture rules (7)
│   ├── state-*.md        # State architecture rules (7)
│   ├── hook-*.md         # Hook patterns rules (6)
│   ├── decomp-*.md       # Component decomposition rules (6)
│   ├── migrate-*.md      # Modern React migration rules (5)
│   ├── couple-*.md       # Coupling & cohesion rules (6)
│   ├── data-*.md         # Data & side effects rules (5)
│   └── safety-*.md       # Refactoring safety rules (5)
└── assets/
    └── templates/
        └── _template.md  # Rule template
```

## Getting Started

```bash
# Install dependencies (if contributing)
pnpm install

# Build AGENTS.md from rules
pnpm build

# Validate skill structure
pnpm validate
```

## Creating a New Rule

1. Determine the category based on the rule's primary concern
2. Use the appropriate prefix from the table below
3. Copy `assets/templates/_template.md` as your starting point
4. Fill in frontmatter and content

### Prefix Reference

| Prefix | Category | Impact |
|--------|----------|--------|
| `arch-` | Component Architecture | CRITICAL |
| `state-` | State Architecture | CRITICAL |
| `hook-` | Hook Patterns | HIGH |
| `decomp-` | Component Decomposition | HIGH |
| `migrate-` | Modern React Migration | MEDIUM-HIGH |
| `couple-` | Coupling & Cohesion | MEDIUM |
| `data-` | Data & Side Effects | MEDIUM |
| `safety-` | Refactoring Safety | LOW-MEDIUM |

## Rule File Structure

Each rule follows this template:

```markdown
---
title: Rule Title Here
impact: HIGH
impactDescription: Quantified impact (e.g., "reduces prop passing by 60%")
tags: prefix, technique, related-concepts
---

## Rule Title Here

1-3 sentences explaining WHY this matters for React architecture.

**Incorrect (what's wrong):**

\`\`\`tsx
// Bad example with comments explaining the cost
\`\`\`

**Correct (what's right):**

\`\`\`tsx
// Good example with comments explaining the benefit
\`\`\`

Reference: [Link](https://example.com)
```

## File Naming Convention

Rule files follow the pattern: `{prefix}-{description}.md`

Examples:
- `arch-compound-components.md` — Component architecture, about compound component pattern
- `state-colocate-with-consumers.md` — State architecture, about state colocation
- `safety-characterization-tests.md` — Refactoring safety, about characterization tests

## Impact Levels

| Level | Description |
|-------|-------------|
| CRITICAL | Core architectural issue; affects maintainability, testability, and scalability |
| HIGH | Strong impact on code quality and developer experience |
| MEDIUM-HIGH | Important for migrating to modern React patterns |
| MEDIUM | Improves module boundaries and data flow clarity |
| LOW-MEDIUM | Creates safety nets for aggressive refactoring |

## Scripts

| Command | Description |
|---------|-------------|
| `pnpm build` | Compiles rules into AGENTS.md |
| `pnpm validate` | Validates skill structure and rules |

## Contributing

1. Check existing rules to avoid duplication
2. Use the rule template (`assets/templates/_template.md`)
3. Include both incorrect and correct examples
4. Quantify impact where possible
5. Reference authoritative documentation
6. Run validation before submitting

## Acknowledgments

This skill draws from:
- [React Documentation](https://react.dev)
- [Thinking in React](https://react.dev/learn/thinking-in-react)
- [Kent C. Dodds Blog](https://kentcdodds.com)
- [Testing Library Guiding Principles](https://testing-library.com/docs/guiding-principles)
- [Patterns.dev](https://patterns.dev)

## License

MIT
