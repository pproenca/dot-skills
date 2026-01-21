# MSW Best Practices

Comprehensive API mocking guide for MSW (Mock Service Worker) v2 applications. This skill helps you set up MSW correctly, write effective request handlers, and integrate with test frameworks.

## Overview

This skill contains 45 rules across 8 categories, organized by impact level:

| Category | Rules | Impact |
|----------|-------|--------|
| Setup & Initialization | 6 | CRITICAL |
| Handler Architecture | 8 | CRITICAL |
| Test Integration | 7 | HIGH |
| Response Patterns | 6 | HIGH |
| Request Matching | 5 | MEDIUM-HIGH |
| GraphQL Mocking | 4 | MEDIUM |
| Advanced Patterns | 5 | MEDIUM |
| Debugging & Performance | 4 | LOW |

## Structure

```
mswjs/
├── SKILL.md              # Entry point with quick reference
├── AGENTS.md             # Compiled comprehensive guide
├── metadata.json         # Version, references, metadata
├── README.md             # This file
├── references/
│   ├── _sections.md      # Category definitions
│   ├── setup-*.md        # Setup rules (6)
│   ├── handler-*.md      # Handler architecture rules (8)
│   ├── test-*.md         # Test integration rules (7)
│   ├── response-*.md     # Response pattern rules (6)
│   ├── match-*.md        # Request matching rules (5)
│   ├── graphql-*.md      # GraphQL mocking rules (4)
│   ├── advanced-*.md     # Advanced pattern rules (5)
│   └── debug-*.md        # Debugging rules (4)
└── assets/
    └── templates/
        └── _template.md  # Rule template
```

## Getting Started

### Using in Claude Code

This skill automatically activates when you're working on:
- MSW handler files (`handlers.ts`, `mocks/*.ts`)
- Test setup files that configure MSW
- API mocking patterns in tests
- REST or GraphQL API mocking

### Manual Commands

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
| `setup-` | Setup & Initialization | CRITICAL |
| `handler-` | Handler Architecture | CRITICAL |
| `test-` | Test Integration | HIGH |
| `response-` | Response Patterns | HIGH |
| `match-` | Request Matching | MEDIUM-HIGH |
| `graphql-` | GraphQL Mocking | MEDIUM |
| `advanced-` | Advanced Patterns | MEDIUM |
| `debug-` | Debugging & Performance | LOW |

## Rule File Structure

Each rule follows this template:

```markdown
---
title: Rule Title Here
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: Quantified impact (e.g., "2-10× improvement")
tags: prefix, technique, related-concepts
---

## Rule Title Here

1-3 sentences explaining WHY this matters.

**Incorrect (what's wrong):**

\`\`\`typescript
// Bad example
\`\`\`

**Correct (what's right):**

\`\`\`typescript
// Good example
\`\`\`

Reference: [Link](https://example.com)
```

## File Naming Convention

Rule files follow the pattern: `{prefix}-{description}.md`

Examples:
- `setup-server-node-entrypoint.md` - Setup category, about Node.js entrypoint
- `handler-happy-path-first.md` - Handler category, about handler organization
- `test-reset-handlers.md` - Test category, about resetting handlers

## Impact Levels

| Level | Description |
|-------|-------------|
| CRITICAL | MSW fails to function without this |
| HIGH | Major degradation in test reliability |
| MEDIUM-HIGH | Significant impact on specific workflows |
| MEDIUM | Noticeable improvement in quality |
| LOW-MEDIUM | Incremental improvement |
| LOW | Minor optimization |

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
5. Reference authoritative sources
6. Run validation before submitting

## Acknowledgments

This skill draws from:
- [MSW Documentation](https://mswjs.io/docs/)
- [MSW Best Practices](https://mswjs.io/docs/best-practices/)
- [MSW v2 Migration Guide](https://mswjs.io/docs/migrations/1.x-to-2.x/)
- [MSW Debugging Runbook](https://mswjs.io/docs/runbook/)

## License

Apache 2.0
