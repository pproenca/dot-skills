# React 19 Best Practices

Comprehensive performance optimization guide for React 19 applications.

## Overview

This skill contains 40+ rules across 8 categories for optimizing React 19 applications. Rules are prioritized by impact from CRITICAL to LOW-MEDIUM.

### Structure

```
react-19/
├── SKILL.md              # Entry point with quick reference
├── AGENTS.md             # Compiled comprehensive guide
├── metadata.json         # Version and references
├── README.md             # This file
└── rules/
    ├── _sections.md      # Category definitions
    └── {prefix}-{slug}.md # Individual rules
```

## Getting Started

```bash
# Install dependencies (if using build scripts)
pnpm install

# Build the compiled AGENTS.md
pnpm build

# Validate the skill
pnpm validate
```

## Creating a New Rule

1. Choose the appropriate category prefix from `_sections.md`
2. Create a new file: `rules/{prefix}-{descriptive-name}.md`
3. Follow the template structure below
4. Run validation to ensure compliance

### Prefix Reference

| Category | Prefix | Impact |
|----------|--------|--------|
| Concurrent Rendering | `conc-` | CRITICAL |
| Server Components | `rsc-` | CRITICAL |
| Actions & Forms | `form-` | HIGH |
| Data Fetching | `data-` | HIGH |
| State Management | `state-` | MEDIUM-HIGH |
| Memoization & Performance | `memo-` | MEDIUM |
| Effects & Events | `effect-` | MEDIUM |
| Component Patterns | `comp-` | LOW-MEDIUM |

## Rule File Structure

```markdown
---
title: Rule Title Here
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: Quantified impact (e.g., "2-10× improvement")
tags: prefix, technique, tool
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

Reference: [Link](https://example.com)
```

## File Naming Convention

Rule files follow the pattern: `{prefix}-{descriptive-slug}.md`

Examples:
- `conc-use-transition.md`
- `rsc-server-client-boundary.md`
- `effect-avoid-unnecessary.md`

## Impact Levels

| Level | Description |
|-------|-------------|
| CRITICAL | Fundamental issues that cause major performance problems |
| HIGH | Significant optimizations with measurable impact |
| MEDIUM-HIGH | Important patterns for common scenarios |
| MEDIUM | Useful optimizations for specific cases |
| LOW-MEDIUM | Minor improvements and best practices |
| LOW | Edge cases and advanced patterns |

## Scripts

```bash
# Validate skill structure and content
node scripts/validate-skill.js ./skills/react-19

# Build AGENTS.md from rules
node scripts/build-agents-md.js ./skills/react-19
```

## Contributing

1. Follow the rule template exactly
2. Include both incorrect and correct examples
3. Quantify impact where possible
4. Reference authoritative sources
5. Run validation before submitting

## Acknowledgments

Based on official React documentation and community best practices. Special emphasis on patterns from "You Might Not Need an Effect" and React 19 release notes.
