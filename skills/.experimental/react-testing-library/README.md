# React Testing Library Best Practices

A comprehensive skill for writing maintainable, user-centric tests with React Testing Library.

## Overview

This skill contains 43 rules across 9 categories, prioritized by impact to guide test writing and code review. It covers query selection, async handling, user interactions, assertions, and common anti-patterns.

### Structure

```
react-testing-library/
├── SKILL.md              # Entry point with quick reference
├── metadata.json         # Version, org, references
├── README.md             # This file
├── references/
│   ├── _sections.md      # Category definitions
│   ├── query-*.md        # Query selection rules (CRITICAL)
│   ├── async-*.md        # Async handling rules (CRITICAL)
│   ├── anti-*.md         # Anti-pattern rules (CRITICAL)
│   ├── user-*.md         # User interaction rules (HIGH)
│   ├── assert-*.md       # Assertion rules (HIGH)
│   ├── setup-*.md        # Component setup rules (MEDIUM)
│   ├── struct-*.md       # Test structure rules (MEDIUM)
│   ├── debug-*.md        # Debugging rules (LOW-MEDIUM)
│   └── a11y-*.md         # Accessibility rules (LOW)
└── assets/
    └── templates/
        └── _template.md  # Template for new rules
```

## Getting Started

```bash
# Install dependencies (if in a project with validation scripts)
pnpm install

# Build compiled documents
pnpm build

# Validate skill structure
pnpm validate
```

## Creating a New Rule

1. Choose the appropriate category prefix based on the rule's focus area
2. Create a new file in `references/` with the naming pattern `{prefix}-{description}.md`
3. Copy the template from `assets/templates/_template.md`
4. Fill in all required sections

### Prefix Reference

| Prefix | Category | Impact |
|--------|----------|--------|
| `query-` | Query Selection | CRITICAL |
| `async-` | Async Handling | CRITICAL |
| `anti-` | Common Anti-Patterns | CRITICAL |
| `user-` | User Interaction | HIGH |
| `assert-` | Assertions | HIGH |
| `setup-` | Component Setup | MEDIUM |
| `struct-` | Test Structure | MEDIUM |
| `debug-` | Debugging | LOW-MEDIUM |
| `a11y-` | Accessibility Testing | LOW |

## Rule File Structure

Each rule file must include:

```markdown
---
title: Rule Title Here
impact: CRITICAL|HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: Quantified impact (e.g., "2-10× improvement")
tags: category-prefix, technique, tool, concept
---

## Rule Title Here

Brief explanation of WHY this matters.

**Incorrect (what's wrong):**

\`\`\`tsx
// Bad code example
\`\`\`

**Correct (what's right):**

\`\`\`tsx
// Good code example
\`\`\`

Reference: [Source](URL)
```

## File Naming Convention

Rule files follow the pattern: `{prefix}-{description}.md`

- **prefix**: 3-8 character category identifier (e.g., `query`, `async`, `anti`)
- **description**: kebab-case description of the rule (e.g., `prefer-role`, `await-findby`)

Examples:
- `query-prefer-role.md` - Query selection rule about preferring getByRole
- `async-await-findby.md` - Async handling rule about awaiting findBy queries
- `anti-container-queries.md` - Anti-pattern rule about avoiding container queries

## Impact Levels

| Level | Description |
|-------|-------------|
| **CRITICAL** | Fundamental issues that cause test failures, false positives, or major maintenance burden |
| **HIGH** | Important patterns that significantly improve test quality and reliability |
| **MEDIUM** | Good practices that improve maintainability and readability |
| **LOW-MEDIUM** | Helpful patterns for specific situations |
| **LOW** | Nice-to-have improvements and advanced techniques |

## Scripts

| Command | Description |
|---------|-------------|
| `pnpm build` | Generate AGENTS.md compiled document |
| `pnpm validate` | Check skill structure against guidelines |
| `pnpm validate --strict` | Fail on warnings as well as errors |

## Contributing

1. Read existing rules to understand the expected format and quality
2. Follow the template structure exactly
3. Include realistic code examples (avoid `foo`, `bar`, generic names)
4. Quantify impact where possible (e.g., "2-10× improvement", "prevents X")
5. Run validation before submitting

## Acknowledgments

- [Testing Library](https://testing-library.com) - Official documentation
- [Kent C. Dodds](https://kentcdodds.com) - Creator guidance and best practices
- [jest-dom](https://github.com/testing-library/jest-dom) - Custom matchers
