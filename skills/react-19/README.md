# React 19 Best Practices Skill

Comprehensive performance optimization guide for React 19 applications.

## Overview

This skill contains 42 rules across 8 categories, designed to help AI agents and developers write performant React 19 code. Rules are prioritized by impact, from critical (Actions, data fetching) to incremental (DOM optimizations).

## Structure

```
react-19/
├── SKILL.md              # Entry point with quick reference
├── AGENTS.md             # Compiled comprehensive guide
├── metadata.json         # Version, org, references
├── README.md             # This file
└── rules/
    ├── _sections.md      # Category definitions
    ├── _template.md      # Rule template
    ├── action-*.md       # Actions & Async Patterns (6 rules)
    ├── async-*.md        # Data Fetching & Suspense (6 rules)
    ├── server-*.md       # Server Components (5 rules)
    ├── compiler-*.md     # React Compiler Optimization (4 rules)
    ├── state-*.md        # State Management (5 rules)
    ├── render-*.md       # Rendering Optimization (6 rules)
    ├── component-*.md    # Component Patterns (5 rules)
    └── dom-*.md          # DOM & Hydration (5 rules)
```

## Getting Started

### Installation

```bash
pnpm install
```

### Build AGENTS.md

```bash
pnpm build
```

### Validate Skill

```bash
pnpm validate
```

## Creating a New Rule

1. Choose the appropriate category based on impact:

| Prefix | Category | Impact |
|--------|----------|--------|
| `action-` | Actions & Async Patterns | CRITICAL |
| `async-` | Data Fetching & Suspense | CRITICAL |
| `server-` | Server Components | HIGH |
| `compiler-` | React Compiler Optimization | HIGH |
| `state-` | State Management | MEDIUM-HIGH |
| `render-` | Rendering Optimization | MEDIUM |
| `component-` | Component Patterns | MEDIUM |
| `dom-` | DOM & Hydration | LOW-MEDIUM |

2. Create a new file: `rules/{prefix}-{description}.md`

3. Use the template structure from `rules/_template.md`

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

**Incorrect (what's wrong):**

\`\`\`tsx
// Bad code example
\`\`\`

**Correct (what's right):**

\`\`\`tsx
// Good code example
\`\`\`

Reference: [Link](URL)
```

## File Naming Convention

Rules follow the pattern: `{prefix}-{description}.md`

- `prefix`: Category identifier (action, async, server, etc.)
- `description`: Kebab-case description of the rule

Examples:
- `action-form-actions.md`
- `async-use-hook-promises.md`
- `server-default-to-server.md`

## Impact Levels

| Level | Description | Example |
|-------|-------------|---------|
| CRITICAL | Prevents major performance problems | Eliminating waterfalls |
| HIGH | Significant performance improvement | 25-60% bundle reduction |
| MEDIUM-HIGH | Notable user-facing improvement | Instant feedback |
| MEDIUM | Measurable optimization | Fewer re-renders |
| LOW-MEDIUM | Incremental improvement | Better debugging |
| LOW | Minor optimization | Cleaner APIs |

## Scripts

| Script | Description |
|--------|-------------|
| `pnpm build` | Compile rules into AGENTS.md |
| `pnpm validate` | Validate skill against guidelines |

## Contributing

1. Read existing rules for style consistency
2. Follow the template structure
3. Include real-world code examples
4. Quantify impact where possible
5. Run validation before submitting

## Acknowledgments

Based on official React 19 documentation and best practices from:
- [react.dev](https://react.dev)
- [React 19 Release Blog](https://react.dev/blog/2024/12/05/react-19)
- [Vercel Engineering Blog](https://vercel.com/blog)
