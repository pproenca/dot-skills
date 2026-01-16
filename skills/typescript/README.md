# TypeScript Best Practices

A comprehensive guide to TypeScript performance optimization, designed for AI agents, LLMs, and developers building high-performance TypeScript applications.

## Overview

This skill contains **42 rules** across **8 categories**, covering:

- **Type System Performance** - Writing types that compile fast
- **Compiler Configuration** - Optimal tsconfig.json settings
- **Async Patterns** - Eliminating runtime waterfalls
- **Module Organization** - Clean imports and tree-shaking
- **Type Safety Patterns** - Preventing runtime errors
- **Memory Management** - Avoiding leaks in long-running apps
- **Runtime Optimization** - Hot-path performance
- **Advanced Patterns** - Branded types, template literals, satisfies

## Structure

```
typescript/
├── SKILL.md           # Quick reference entry point
├── AGENTS.md          # Full compiled guide
├── metadata.json      # Version and references
├── README.md          # This file
└── rules/
    ├── _sections.md   # Category definitions
    ├── type-*.md      # Type system rules (7)
    ├── config-*.md    # Compiler config rules (6)
    ├── async-*.md     # Async pattern rules (5)
    ├── module-*.md    # Module organization rules (5)
    ├── safety-*.md    # Type safety rules (6)
    ├── mem-*.md       # Memory management rules (5)
    ├── runtime-*.md   # Runtime optimization rules (6)
    └── advanced-*.md  # Advanced pattern rules (3)
```

## Getting Started

```bash
# Install dependencies (from repo root)
pnpm install

# Build AGENTS.md from rules
pnpm build

# Validate skill structure
pnpm validate
```

## Creating a New Rule

1. Choose the appropriate category from `rules/_sections.md`
2. Create a new file: `rules/{prefix}-{description}.md`
3. Use the template structure (see below)
4. Run `pnpm build` to regenerate AGENTS.md
5. Run `pnpm validate` to check for errors

### Prefix Reference

| Category | Prefix | Impact |
|----------|--------|--------|
| Type System Performance | `type-` | CRITICAL |
| Compiler Configuration | `config-` | CRITICAL |
| Async Patterns | `async-` | HIGH |
| Module Organization | `module-` | HIGH |
| Type Safety Patterns | `safety-` | MEDIUM-HIGH |
| Memory Management | `mem-` | MEDIUM |
| Runtime Optimization | `runtime-` | LOW-MEDIUM |
| Advanced Patterns | `advanced-` | LOW |

## Rule File Structure

```markdown
---
title: Rule Title Here
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: Quantified impact (e.g., "2-10× improvement")
tags: prefix, technique, related-concepts
---

## Rule Title Here

Brief explanation of WHY this matters (1-3 sentences).

**Incorrect (description of problem):**

\`\`\`typescript
// Code with performance/safety issue
\`\`\`

**Correct (description of solution):**

\`\`\`typescript
// Optimized/safe code
\`\`\`

Reference: [Link](url)
```

## File Naming Convention

Rules follow the pattern: `{prefix}-{description}.md`

- `prefix`: Category identifier (3-8 chars) from _sections.md
- `description`: Kebab-case description of the rule

Examples:
- `type-interfaces-over-intersections.md`
- `async-parallel-promises.md`
- `config-enable-incremental.md`

## Impact Levels

| Level | Description | Typical Improvement |
|-------|-------------|---------------------|
| CRITICAL | Must fix immediately | 2-10× improvement |
| HIGH | Fix in current sprint | 50-200% improvement |
| MEDIUM-HIGH | Fix soon | 30-50% improvement |
| MEDIUM | Fix when convenient | 20-30% improvement |
| LOW-MEDIUM | Nice to have | 10-20% improvement |
| LOW | Edge cases only | Situational |

## Scripts

From the repository root:

```bash
# Build AGENTS.md from individual rules
pnpm build

# Validate skill against quality checklist
pnpm validate

# Validate with AGENTS.md verification
pnpm validate -- --verify-generated
```

## Contributing

1. Follow the rule template structure exactly
2. Include both incorrect and correct code examples
3. Quantify impact where possible
4. Reference authoritative sources
5. Run validation before submitting

## Acknowledgments

- [TypeScript Performance Wiki](https://github.com/microsoft/TypeScript/wiki/Performance)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/)
- [V8 JavaScript Engine Blog](https://v8.dev/blog)
- [Node.js Documentation](https://nodejs.org/en/learn/diagnostics/memory)
