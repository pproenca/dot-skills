# Test-Driven Development Best Practices

A comprehensive collection of TDD best practices for AI agents and LLMs, containing 42 rules across 8 categories.

## Overview

This skill provides guidelines for writing effective tests using Test-Driven Development methodology. Rules are organized by impact level, from critical (red-green-refactor cycle) to strategic (test pyramid).

## Structure

```
test-driven-development/
├── SKILL.md              # Entry point with quick reference
├── AGENTS.md             # Compiled comprehensive guide
├── metadata.json         # Version, organization, references
├── README.md             # This file
└── rules/
    ├── _sections.md      # Category definitions
    ├── cycle-*.md        # Red-green-refactor cycle rules
    ├── design-*.md       # Test design principle rules
    ├── isolate-*.md      # Test isolation rules
    ├── data-*.md         # Test data management rules
    ├── assert-*.md       # Assertion rules
    ├── org-*.md          # Test organization rules
    ├── perf-*.md         # Test performance rules
    └── strat-*.md        # Test strategy rules
```

## Getting Started

1. Install dependencies:
   ```bash
   pnpm install
   ```

2. Build the compiled guide:
   ```bash
   pnpm build
   ```

3. Validate the skill:
   ```bash
   pnpm validate
   ```

## Creating a New Rule

1. Determine the appropriate category from `rules/_sections.md`
2. Create a new file with the category prefix: `{prefix}-{description}.md`
3. Use the frontmatter template:
   ```yaml
   ---
   title: Rule Title Here
   impact: CRITICAL|HIGH|MEDIUM|LOW
   impactDescription: Quantified impact (e.g., "2-10× improvement")
   tags: prefix, keyword1, keyword2
   ---
   ```
4. Run validation to check formatting

### Category Prefixes

| Prefix | Category | Impact |
|--------|----------|--------|
| `cycle-` | Red-Green-Refactor Cycle | CRITICAL |
| `design-` | Test Design Principles | CRITICAL |
| `isolate-` | Test Isolation & Dependencies | HIGH |
| `data-` | Test Data Management | HIGH |
| `assert-` | Assertions & Verification | MEDIUM |
| `org-` | Test Organization & Structure | MEDIUM |
| `perf-` | Test Performance & Reliability | MEDIUM |
| `strat-` | Test Pyramid & Strategy | LOW |

## Rule File Structure

Each rule file should follow this template:

```markdown
---
title: Rule Title
impact: MEDIUM
impactDescription: Quantified impact description
tags: prefix, tag1, tag2
---

## Rule Title

Brief explanation of why this rule matters (1-3 sentences).

**Incorrect (what's wrong):**

\`\`\`typescript
// Bad code example with comments explaining the issue
\`\`\`

**Correct (what's right):**

\`\`\`typescript
// Good code example with comments explaining the benefit
\`\`\`

Reference: [Link to authoritative source](https://example.com)
```

## File Naming Convention

Rule files follow the pattern: `{prefix}-{description}.md`

- `prefix`: Category identifier (3-8 characters)
- `description`: Lowercase, hyphen-separated description

Examples:
- `cycle-write-test-first.md`
- `design-aaa-pattern.md`
- `isolate-mock-external-dependencies.md`

## Impact Levels

| Level | Description | Examples |
|-------|-------------|----------|
| CRITICAL | Foundational practices that prevent major issues | Red-green cycle, test-first approach |
| HIGH | Important practices with significant benefits | Test isolation, proper mocking |
| MEDIUM | Good practices that improve quality | Clear assertions, organization |
| LOW | Strategic considerations | Test pyramid, coverage targets |

## Scripts

- `pnpm build` - Compiles all rules into AGENTS.md
- `pnpm validate` - Validates skill structure and content
- `pnpm lint` - Checks markdown formatting

## Contributing

1. Read existing rules to understand the style
2. Research authoritative sources for new rules
3. Follow the rule template exactly
4. Run validation before submitting
5. Include references to credible sources

## Acknowledgments

This skill synthesizes best practices from:

- Kent Beck - Test Driven Development: By Example
- Martin Fowler - TDD articles and Practical Test Pyramid
- Robert C. Martin - Clean Code and TDD cycles
- Microsoft Learn - Unit testing best practices
- Google Testing Blog - Coverage best practices
