# React Principles Best Practices

Comprehensive React development principles skill for AI coding agents. Based on the official React documentation from react.dev/learn.

## Overview

This skill provides 52 rules across 8 categories to help developers write React code following official best practices. Rules are prioritized by impact, from critical component purity principles to practical event handling patterns.

| Category | Rules | Impact |
|----------|-------|--------|
| Component Purity | 9 | HIGH |
| State Structure | 10 | HIGH |
| State Sharing | 6 | HIGH |
| Effect Patterns | 10 | HIGH |
| Refs Usage | 5 | MEDIUM |
| Reducer Patterns | 5 | MEDIUM |
| Context Patterns | 4 | MEDIUM |
| Event Handling | 4 | MEDIUM |

## Structure

```
react-principle-engineer/
├── SKILL.md              # Entry point with quick reference
├── AGENTS.md             # Compiled comprehensive guide
├── metadata.json         # Version, references, metadata
├── README.md             # This file
├── references/
│   ├── _sections.md      # Category definitions
│   ├── pure-*.md         # Component purity rules (9)
│   ├── state-*.md        # State structure rules (10)
│   ├── share-*.md        # State sharing rules (6)
│   ├── effect-*.md       # Effect patterns rules (10)
│   ├── ref-*.md          # Refs usage rules (5)
│   ├── reducer-*.md      # Reducer patterns rules (5)
│   ├── context-*.md      # Context patterns rules (4)
│   └── event-*.md        # Event handling rules (4)
└── assets/
    └── templates/
        └── _template.md  # Rule template
```

## Getting Started

### Using in Claude Code

This skill automatically activates when you're working on:
- React component development with hooks
- State management architecture decisions
- Effect and synchronization patterns
- Debugging re-renders or stale state issues

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
| `pure-` | Component Purity | HIGH |
| `state-` | State Structure | HIGH |
| `share-` | State Sharing | HIGH |
| `effect-` | Effect Patterns | HIGH |
| `ref-` | Refs Usage | MEDIUM |
| `reducer-` | Reducer Patterns | MEDIUM |
| `context-` | Context Patterns | MEDIUM |
| `event-` | Event Handling | MEDIUM |

## Rule File Structure

Each rule follows this template:

```markdown
---
title: Rule Title Here
impact: HIGH|MEDIUM|LOW
impactDescription: Quantified impact (e.g., "prevents stale closures in 90% of cases")
tags: prefix, technique, related-concepts
---

## Rule Title Here

1-3 sentences explaining WHY this matters for React development.

**Incorrect (what's wrong):**

\`\`\`tsx
// Bad example with comments explaining the cost
\`\`\`

**Correct (what's right):**

\`\`\`tsx
// Good example with comments explaining the benefit
\`\`\`

Reference: [Link](https://react.dev/learn/...)
```

## File Naming Convention

Rule files follow the pattern: `{prefix}-{description}.md`

Examples:
- `pure-no-external-mutations.md` - Component purity, about avoiding external mutations
- `effect-cleanup.md` - Effect patterns, about cleanup functions
- `state-avoid-contradictions.md` - State structure, about avoiding contradictory state

## Impact Levels

| Level | Description |
|-------|-------------|
| HIGH | Core React principle; violating causes bugs, performance issues, or broken features |
| MEDIUM | Important pattern; improves code quality and maintainability |
| LOW | Minor optimization or stylistic preference |

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
5. Reference official React documentation
6. Run validation before submitting

## Key Principles

1. **Components Are Pure Functions** - Same inputs always produce same outputs
2. **State Is Minimal and Normalized** - Store only what can't be derived
3. **Effects Synchronize, Don't React** - Think start/stop sync, not lifecycle
4. **Events Drive Side Effects** - User actions trigger effects through handlers

## Acknowledgments

This skill is extracted from:
- [React Learn Documentation](https://react.dev/learn) - Official React documentation
- [Keeping Components Pure](https://react.dev/learn/keeping-components-pure)
- [Choosing the State Structure](https://react.dev/learn/choosing-the-state-structure)
- [Lifecycle of Reactive Effects](https://react.dev/learn/lifecycle-of-reactive-effects)
- [Extracting State Logic into a Reducer](https://react.dev/learn/extracting-state-logic-into-a-reducer)
- [Passing Data Deeply with Context](https://react.dev/learn/passing-data-deeply-with-context)

## License

MIT
