# Tailwind CSS v4 Best Practices Skill

A comprehensive performance optimization and best practices guide for Tailwind CSS v4, designed for AI agents and LLMs.

## Overview

This skill contains 42 rules across 8 categories, covering:
- Build configuration and tooling optimization
- CSS generation and @theme directive usage
- Bundle size optimization
- Utility class patterns and v4 syntax changes
- Component architecture and @apply best practices
- Theming and design tokens
- Responsive design and container queries
- Animation and transition performance

## Structure

```
tailwindcss-v4-style/
├── SKILL.md              # Entry point with quick reference
├── AGENTS.md             # Compiled comprehensive guide
├── metadata.json         # Version, organization, references
├── README.md             # This file
├── references/
│   ├── _sections.md      # Category definitions
│   ├── build-*.md        # Build configuration rules (6)
│   ├── gen-*.md          # CSS generation rules (6)
│   ├── bundle-*.md       # Bundle optimization rules (5)
│   ├── util-*.md         # Utility pattern rules (6)
│   ├── comp-*.md         # Component architecture rules (5)
│   ├── theme-*.md        # Theming rules (5)
│   ├── resp-*.md         # Responsive design rules (5)
│   └── anim-*.md         # Animation rules (4)
└── assets/
    └── templates/
        └── _template.md  # Rule template for extensions
```

## Getting Started

### Installation

```bash
# Install dependencies
pnpm install

# Build the compiled AGENTS.md
pnpm build

# Validate the skill
pnpm validate
```

### Usage

Reference this skill when working with Tailwind CSS v4 projects. The rules are organized by impact level:

1. **CRITICAL** - Build configuration and CSS generation (address first)
2. **HIGH** - Bundle optimization and utility patterns
3. **MEDIUM-HIGH** - Component architecture
4. **MEDIUM** - Theming and responsive design
5. **LOW-MEDIUM** - Animation and transitions

## Creating a New Rule

1. Choose the appropriate category and prefix from the table below
2. Create a new file: `references/{prefix}-{description}.md`
3. Use the template from `assets/templates/_template.md`
4. Run validation to ensure compliance

### Prefix Reference

| Category | Prefix | Impact |
|----------|--------|--------|
| Build Configuration | `build-` | CRITICAL |
| CSS Generation | `gen-` | CRITICAL |
| Bundle Optimization | `bundle-` | HIGH |
| Utility Patterns | `util-` | HIGH |
| Component Architecture | `comp-` | MEDIUM-HIGH |
| Theming & Design Tokens | `theme-` | MEDIUM |
| Responsive & Adaptive | `resp-` | MEDIUM |
| Animation & Transitions | `anim-` | LOW-MEDIUM |

## Rule File Structure

```markdown
---
title: Rule Title
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: Quantified impact (e.g., "2-10× improvement")
tags: prefix, technique, tool, related-concepts
---

## Rule Title

Brief explanation of WHY this matters (1-3 sentences).

**Incorrect (problem description):**

\`\`\`language
// Bad code example
\`\`\`

**Correct (solution description):**

\`\`\`language
// Good code example
\`\`\`

Reference: [Title](URL)
```

## File Naming Convention

Rule files follow the pattern: `{prefix}-{descriptive-slug}.md`

Examples:
- `build-vite-plugin.md`
- `gen-css-first-config.md`
- `util-renamed-utilities.md`

## Impact Levels

| Level | Description |
|-------|-------------|
| CRITICAL | Must fix immediately; 5-100× performance impact |
| HIGH | Address in current sprint; 2-10× impact |
| MEDIUM-HIGH | Address soon; measurable improvement |
| MEDIUM | Address when convenient; noticeable improvement |
| LOW-MEDIUM | Address if time permits; minor optimization |
| LOW | Nice to have; minimal impact |

## Scripts

```bash
# Build AGENTS.md from references
pnpm build

# Validate skill structure and content
pnpm validate

# Validate with strict mode
pnpm validate --strict
```

## Contributing

1. Read existing rules in the same category for style consistency
2. Follow the minimal diff philosophy (incorrect/correct examples should be nearly identical)
3. Quantify impact where possible
4. Include authoritative references
5. Run validation before submitting

## Acknowledgments

Based on official Tailwind CSS v4 documentation and best practices from:
- [Tailwind CSS Documentation](https://tailwindcss.com/docs)
- [Tailwind CSS v4.0 Release Blog](https://tailwindcss.com/blog/tailwindcss-v4)
- [Tailwind CSS Upgrade Guide](https://tailwindcss.com/docs/upgrade-guide)
