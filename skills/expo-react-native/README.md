# Expo React Native Best Practices

A comprehensive performance optimization skill for Expo React Native applications, containing 42 rules across 8 categories.

## Overview

This skill provides actionable performance guidelines for building fast, responsive Expo React Native applications. Rules are prioritized by impact, from critical startup optimizations to incremental memory improvements.

### Structure

```
expo-react-native/
├── SKILL.md              # Entry point with quick reference
├── AGENTS.md             # Compiled comprehensive guide
├── metadata.json         # Version, organization, references
├── README.md             # This file
├── references/
│   ├── _sections.md      # Category definitions
│   ├── launch-*.md       # Launch time optimization rules
│   ├── bundle-*.md       # Bundle size optimization rules
│   ├── list-*.md         # List virtualization rules
│   ├── image-*.md        # Image optimization rules
│   ├── nav-*.md          # Navigation performance rules
│   ├── rerender-*.md     # Re-render prevention rules
│   ├── anim-*.md         # Animation performance rules
│   └── mem-*.md          # Memory management rules
└── assets/
    └── templates/
        └── _template.md  # Template for new rules
```

## Getting Started

### Installation

```bash
pnpm install
```

### Build the Compiled Guide

```bash
pnpm build
```

### Validate the Skill

```bash
pnpm validate
```

## Creating a New Rule

1. Identify which category the rule belongs to (see table below)
2. Create a new file in `references/` with the appropriate prefix
3. Follow the template structure from `assets/templates/_template.md`
4. Run validation to ensure compliance

### Prefix Reference

| Category | Prefix | Impact |
|----------|--------|--------|
| Launch Time Optimization | `launch-` | CRITICAL |
| Bundle Size Optimization | `bundle-` | CRITICAL |
| List Virtualization | `list-` | HIGH |
| Image Optimization | `image-` | HIGH |
| Navigation Performance | `nav-` | MEDIUM-HIGH |
| Re-render Prevention | `rerender-` | MEDIUM |
| Animation Performance | `anim-` | MEDIUM |
| Memory Management | `mem-` | LOW-MEDIUM |

## Rule File Structure

Each rule file must follow this structure:

```markdown
---
title: Rule Title Here
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: Quantified impact (e.g., "2-10× improvement")
tags: prefix, technique, tool, concept
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

Rule files follow the pattern: `{prefix}-{description}.md`

- **prefix**: Category identifier (e.g., `launch`, `list`, `image`)
- **description**: Kebab-case descriptor (e.g., `splash-screen-control`, `use-flashlist`)

Examples:
- `launch-hermes-engine.md`
- `list-use-flashlist.md`
- `image-use-webp-format.md`

## Impact Levels

| Level | Description | Examples |
|-------|-------------|----------|
| CRITICAL | Foundational issues with multiplicative effects | Startup time, bundle size |
| HIGH | Significant user-facing impact | List performance, image loading |
| MEDIUM-HIGH | Important for smooth UX | Navigation, data fetching |
| MEDIUM | Noticeable improvements | Re-renders, animations |
| LOW-MEDIUM | Incremental gains | Memory leaks, cleanup |
| LOW | Edge case optimizations | Micro-optimizations |

## Scripts

| Command | Description |
|---------|-------------|
| `pnpm build` | Compile rules into AGENTS.md |
| `pnpm validate` | Validate skill structure and content |
| `pnpm lint` | Check markdown formatting |

## Contributing

1. Read existing rules to understand the style
2. Follow the template exactly
3. Include realistic code examples
4. Quantify impact where possible
5. Run validation before submitting

### Quality Guidelines

- Use imperative verbs: "Use", "Avoid", "Enable"
- Quantify claims: "2-10× improvement" not "faster"
- Show realistic code, not strawman examples
- Keep incorrect/correct examples minimal diff
- Include authoritative references

## Acknowledgments

Built with guidance from:
- [React Native Performance Documentation](https://reactnative.dev/docs/performance)
- [Expo Documentation](https://docs.expo.dev)
- [Callstack React Native Optimization Guide](https://www.callstack.com/ebooks/the-ultimate-guide-to-react-native-optimization)
- [FlashList by Shopify](https://shopify.github.io/flash-list/)
- [React Native Reanimated](https://docs.swmansion.com/react-native-reanimated/)
