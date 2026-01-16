# Next.js 16 App Router Best Practices

Performance optimization guidelines for Next.js 16 App Router applications.

## Overview

This skill contains 45 rules across 8 categories, prioritized by performance impact:

| Category | Prefix | Impact | Rules |
|----------|--------|--------|-------|
| Async Data Fetching | `async-` | CRITICAL | 6 |
| Bundle Optimization | `bundle-` | CRITICAL | 5 |
| Server Components | `server-` | HIGH | 6 |
| Caching Strategies | `cache-` | HIGH | 5 |
| Rendering Patterns | `render-` | MEDIUM | 5 |
| Route Architecture | `route-` | MEDIUM | 5 |
| Client Components | `client-` | MEDIUM | 5 |
| Advanced Patterns | `advanced-` | LOW | 8 |

## Structure

```
nextjs-16-app-router/
├── SKILL.md              # Quick reference entry point
├── AGENTS.md             # Full compiled guide
├── metadata.json         # Version and references
├── README.md             # This file
└── rules/
    ├── _sections.md      # Category definitions
    ├── async-*.md        # Async data fetching rules
    ├── bundle-*.md       # Bundle optimization rules
    ├── server-*.md       # Server component rules
    ├── cache-*.md        # Caching strategy rules
    ├── render-*.md       # Rendering pattern rules
    ├── route-*.md        # Route architecture rules
    ├── client-*.md       # Client component rules
    └── advanced-*.md     # Advanced pattern rules
```

## Getting Started

```bash
# Install dependencies
pnpm install

# Build AGENTS.md from rules
pnpm build

# Validate the skill
pnpm validate
```

## Creating a New Rule

1. Identify the category from the prefix table above
2. Create a new file: `rules/{prefix}-{descriptive-name}.md`
3. Use the template below
4. Run validation to check formatting

### Prefix Reference

| Prefix | Category | Impact |
|--------|----------|--------|
| `async-` | Async Data Fetching | CRITICAL |
| `bundle-` | Bundle Optimization | CRITICAL |
| `server-` | Server Components | HIGH |
| `cache-` | Caching Strategies | HIGH |
| `render-` | Rendering Patterns | MEDIUM |
| `route-` | Route Architecture | MEDIUM |
| `client-` | Client Components | MEDIUM |
| `advanced-` | Advanced Patterns | LOW |

## Rule File Structure

```markdown
---
title: Rule Title Here
impact: CRITICAL|HIGH|MEDIUM|LOW
impactDescription: Quantified impact (e.g., "2-10× improvement")
tags: prefix, technique, related-concept
---

## Rule Title Here

Brief explanation of WHY this matters (1-3 sentences).

**Incorrect (description of problem):**

\`\`\`typescript
// Bad code example
\`\`\`

**Correct (description of solution):**

\`\`\`typescript
// Good code example
\`\`\`

Reference: [Link text](URL)
```

## File Naming Convention

Rule files follow the pattern: `{prefix}-{descriptive-slug}.md`

- Prefix must match a category from `_sections.md`
- Slug should be lowercase with hyphens
- Be descriptive but concise

Examples:
- `async-parallel-fetching.md`
- `bundle-dynamic-imports.md`
- `cache-revalidate-on-demand.md`

## Impact Levels

| Level | Description |
|-------|-------------|
| CRITICAL | 2-10× improvement, eliminates major bottlenecks |
| HIGH | Significant gains, reduces server load or bundle size |
| MEDIUM | Noticeable improvement, better UX |
| LOW | Incremental gains, polish and optimization |

## Scripts

| Command | Description |
|---------|-------------|
| `pnpm build` | Compile rules into AGENTS.md |
| `pnpm validate` | Check all rules for formatting issues |

## Contributing

1. Read the existing rules to understand the format
2. Create your rule file following the template
3. Run validation before submitting
4. Ensure code examples are production-realistic
5. Quantify impact where possible

## Acknowledgments

- [Next.js Documentation](https://nextjs.org/docs)
- [React Documentation](https://react.dev)
- [Vercel Engineering Blog](https://vercel.com/blog)
- [Web Vitals](https://web.dev/vitals)
