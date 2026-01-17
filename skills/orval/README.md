# Orval OpenAPI Best Practices

Comprehensive best practices for generating type-safe TypeScript clients from OpenAPI specifications using Orval.

## Overview

This skill provides 42 rules across 8 categories covering the complete Orval workflow:

1. **OpenAPI Specification Quality** - Ensure your spec generates clean, type-safe code
2. **Configuration Architecture** - Choose the right mode, client, and structure
3. **Output Structure & Organization** - Optimize for tree-shaking and maintainability
4. **Custom Client & Mutators** - Handle auth, errors, and transformations
5. **Query Library Integration** - React Query, SWR, and Vue Query patterns
6. **Type Safety & Validation** - Zod schemas and runtime validation
7. **Mock Generation & Testing** - MSW handlers and realistic test data
8. **Advanced Patterns** - Transformers, overrides, and edge cases

## Structure

```
orval-openapi/
├── SKILL.md           # Entry point with quick reference
├── AGENTS.md          # Compiled comprehensive guide
├── metadata.json      # Version, organization, references
├── README.md          # This file
└── rules/
    ├── _sections.md   # Category definitions
    ├── _template.md   # Rule template
    ├── spec-*.md      # OpenAPI spec rules (5)
    ├── config-*.md    # Configuration rules (6)
    ├── output-*.md    # Output structure rules (5)
    ├── mutator-*.md   # Custom client rules (6)
    ├── query-*.md     # Query library rules (6)
    ├── types-*.md     # Type safety rules (5)
    ├── mock-*.md      # Mock generation rules (5)
    └── adv-*.md       # Advanced pattern rules (4)
```

## Getting Started

### Installation

```bash
pnpm install
```

### Build

```bash
pnpm build
```

### Validate

```bash
pnpm validate
```

## Creating a New Rule

1. Choose the appropriate category prefix:

| Category | Prefix | Impact |
|----------|--------|--------|
| OpenAPI Specification Quality | `spec-` | CRITICAL |
| Configuration Architecture | `config-` | CRITICAL |
| Output Structure & Organization | `output-` | HIGH |
| Custom Client & Mutators | `mutator-` | HIGH |
| Query Library Integration | `query-` | MEDIUM-HIGH |
| Type Safety & Validation | `types-` | MEDIUM |
| Mock Generation & Testing | `mock-` | MEDIUM |
| Advanced Patterns | `adv-` | LOW |

2. Create a new file: `rules/{prefix}-{description}.md`

3. Follow the template in `rules/_template.md`

## Rule File Structure

```markdown
---
title: Rule Title Here
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: Quantified impact (e.g., "2-10× improvement")
tags: prefix, technique, related-concepts
---

## Rule Title Here

Brief explanation of WHY this matters.

**Incorrect (description of problem):**

\`\`\`typescript
// Bad example
\`\`\`

**Correct (description of solution):**

\`\`\`typescript
// Good example
\`\`\`

Reference: [Title](https://example.com)
```

## File Naming Convention

Rules follow the pattern: `{prefix}-{description}.md`

- `prefix`: Category identifier (3-8 chars)
- `description`: Kebab-case description of the rule

Examples:
- `spec-operationid-unique.md`
- `config-mode-selection.md`
- `mutator-token-refresh.md`

## Impact Levels

| Level | Description |
|-------|-------------|
| CRITICAL | Prevents major issues, affects all downstream code |
| HIGH | Significant improvement, affects multiple areas |
| MEDIUM-HIGH | Notable improvement in specific scenarios |
| MEDIUM | Meaningful optimization for common cases |
| LOW-MEDIUM | Minor improvements, situational benefit |
| LOW | Edge cases, advanced scenarios |

## Scripts

- `pnpm build` - Compiles rules into AGENTS.md
- `pnpm validate` - Validates skill structure and content
- `pnpm lint` - Lints markdown files

## Contributing

1. Follow the rule template exactly
2. Include both incorrect AND correct examples
3. Quantify impact where possible
4. Reference authoritative sources
5. Run validation before submitting

## Acknowledgments

- [Orval](https://orval.dev) - Official documentation
- [TanStack Query](https://tanstack.com/query) - React Query integration
- [MSW](https://mswjs.io) - Mock Service Worker for testing
