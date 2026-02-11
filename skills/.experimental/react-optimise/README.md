# React Optimise Best Practices

Application-level performance optimization guide for React applications, designed for AI agents and LLMs.

## Overview

This skill provides 43 rules across 8 categories to optimize React application performance. Complements the `react` skill (API-level patterns) with holistic optimization strategies covering bundling, rendering, data fetching, Core Web Vitals, profiling, and memory management.

## Structure

```
react-optimise/
├── SKILL.md              # Entry point with quick reference
├── AGENTS.md             # Compiled comprehensive guide
├── metadata.json         # Version, references, metadata
├── README.md             # This file
├── references/
│   ├── _sections.md      # Category definitions
│   ├── compiler-*.md     # React Compiler mastery rules (6)
│   ├── bundle-*.md       # Bundle & loading rules (6)
│   ├── render-*.md       # Rendering optimization rules (6)
│   ├── fetch-*.md        # Data fetching performance rules (5)
│   ├── cwv-*.md          # Core Web Vitals rules (5)
│   ├── sub-*.md          # State & subscription rules (5)
│   ├── profile-*.md      # Profiling & measurement rules (5)
│   └── mem-*.md          # Memory management rules (5)
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
| `compiler-` | React Compiler Mastery | CRITICAL |
| `bundle-` | Bundle & Loading | CRITICAL |
| `render-` | Rendering Optimization | HIGH |
| `fetch-` | Data Fetching Performance | HIGH |
| `cwv-` | Core Web Vitals | MEDIUM-HIGH |
| `sub-` | State & Subscription Performance | MEDIUM-HIGH |
| `profile-` | Profiling & Measurement | MEDIUM |
| `mem-` | Memory Management | LOW-MEDIUM |

## Rule File Structure

Each rule follows this template:

```markdown
---
title: Rule Title Here
impact: HIGH
impactDescription: Quantified impact (e.g., "2-10x improvement")
tags: prefix, technique, related-concepts
---

## Rule Title Here

1-3 sentences explaining WHY this matters for React performance.

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
- `compiler-friendly-code.md` — React Compiler, about compiler-friendly patterns
- `bundle-route-splitting.md` — Bundle optimization, about route-level code splitting
- `cwv-inp-optimization.md` — Core Web Vitals, about Interaction to Next Paint

## Impact Levels

| Level | Description |
|-------|-------------|
| CRITICAL | Must-do optimization; directly affects load time, TTI, or compiler adoption |
| HIGH | Strong impact on rendering performance and user experience |
| MEDIUM-HIGH | Measurable improvement for medium-to-large applications |
| MEDIUM | Important for ongoing performance maintenance and debugging |
| LOW-MEDIUM | Relevant for long-lived SPAs and complex resource management |

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
- [React Compiler Blog Post](https://react.dev/blog/2025/10/07/react-compiler-1)
- [Web.dev Core Web Vitals](https://web.dev/articles/vitals)
- [Chrome DevTools Performance](https://developer.chrome.com/docs/devtools/performance)
- [TanStack Virtual](https://tanstack.com/virtual)

## License

MIT
