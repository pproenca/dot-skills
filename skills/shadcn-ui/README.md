# shadcn/ui Best Practices

A comprehensive best practices skill for building applications with shadcn/ui, Radix primitives, and Tailwind CSS.

## Overview

This skill provides 42 rules across 8 categories, covering:

- **Component Architecture** - Proper Radix primitive usage, CVA patterns, ref forwarding
- **Accessibility** - ARIA preservation, focus management, keyboard navigation
- **Styling & Theming** - CSS variables, dark mode, Tailwind patterns
- **Form Patterns** - React Hook Form integration, Zod validation
- **Data Display** - TanStack Table, virtualization, loading states
- **Component Composition** - Compound components, responsive patterns
- **Performance** - Lazy loading, memoization, bundle optimization
- **State Management** - Controlled vs uncontrolled, state colocation

## Structure

```
shadcn-ui/
├── SKILL.md              # Quick reference and navigation
├── AGENTS.md             # Compiled guide for AI agents
├── README.md             # This file
├── metadata.json         # Version and reference information
├── references/
│   ├── _sections.md      # Category definitions
│   ├── arch-*.md         # Component architecture rules (6)
│   ├── a11y-*.md         # Accessibility rules (5)
│   ├── style-*.md        # Styling rules (6)
│   ├── form-*.md         # Form pattern rules (5)
│   ├── data-*.md         # Data display rules (5)
│   ├── comp-*.md         # Composition rules (6)
│   ├── perf-*.md         # Performance rules (5)
│   └── state-*.md        # State management rules (4)
└── assets/
    └── templates/
        └── _template.md  # Rule template
```

## Getting Started

### Installation

```bash
pnpm install
```

### Building

```bash
pnpm build
```

### Validation

```bash
pnpm validate
```

## Creating a New Rule

1. Choose the appropriate category prefix:

   | Category | Prefix | Impact |
   |----------|--------|--------|
   | Component Architecture | `arch-` | CRITICAL |
   | Accessibility | `a11y-` | CRITICAL |
   | Styling & Theming | `style-` | HIGH |
   | Form Patterns | `form-` | HIGH |
   | Data Display | `data-` | MEDIUM-HIGH |
   | Component Composition | `comp-` | MEDIUM |
   | Performance | `perf-` | MEDIUM |
   | State Management | `state-` | LOW-MEDIUM |

2. Create a new file in `references/` with the naming pattern: `{prefix}-{description}.md`

3. Use the template structure from `assets/templates/_template.md`

4. Run validation to ensure compliance

## Rule File Structure

Each rule file follows this structure:

```markdown
---
title: Rule Title
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: Quantified impact (e.g., "2-10× improvement")
tags: prefix, technique, tools, concepts
---

## Rule Title

Brief explanation of WHY this matters (1-3 sentences).

**Incorrect (what's wrong):**

\`\`\`tsx
// Bad code example with comment explaining the cost
\`\`\`

**Correct (what's right):**

\`\`\`tsx
// Good code example with comment explaining the benefit
\`\`\`

Reference: [Source](url)
```

## File Naming Convention

Rule files use the pattern: `{prefix}-{kebab-case-description}.md`

Examples:
- `arch-use-asChild-for-custom-triggers.md`
- `a11y-preserve-aria-attributes.md`
- `style-use-css-variables-for-theming.md`

## Impact Levels

| Level | Description | Examples |
|-------|-------------|----------|
| CRITICAL | Foundational - wrong patterns cascade everywhere | Component structure, accessibility |
| HIGH | Significant UX/DX impact | Theming, form validation |
| MEDIUM-HIGH | Important for specific use cases | Data tables, loading states |
| MEDIUM | Improves quality noticeably | Composition, performance |
| LOW-MEDIUM | Nice to have, situational | State patterns |
| LOW | Edge cases or micro-optimizations | Advanced patterns |

## Scripts

| Command | Description |
|---------|-------------|
| `pnpm build` | Build AGENTS.md from references |
| `pnpm validate` | Validate skill against guidelines |
| `pnpm lint` | Lint markdown files |

## Contributing

1. Read existing rules to understand the style
2. Create your rule following the template
3. Run validation before submitting
4. Ensure code examples are realistic and runnable

## Acknowledgments

- [shadcn/ui](https://ui.shadcn.com/) - The component library
- [Radix UI](https://www.radix-ui.com/) - Accessible primitives
- [Tailwind CSS](https://tailwindcss.com/) - Utility-first CSS
- [React Hook Form](https://react-hook-form.com/) - Form management
- [TanStack](https://tanstack.com/) - Table and virtual list libraries
