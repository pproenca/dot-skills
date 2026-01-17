# UI/UX Frontend Design Best Practices

A comprehensive guide to UI/UX and frontend design best practices, designed for AI agents, LLMs, and developers building accessible, performant, and user-friendly web interfaces.

## Overview

This skill contains **42 rules** across **8 categories**, covering:

- **Accessibility & WCAG** - Semantic HTML, keyboard navigation, focus indicators
- **Core Web Vitals** - LCP, CLS, INP optimization for SEO and UX
- **Visual Hierarchy & Layout** - Whitespace, grid systems, CTAs
- **Responsive Design** - Mobile-first, fluid typography, container queries
- **Typography** - Font loading, line height, readability
- **Color & Contrast** - WCAG compliance, dark mode, design tokens
- **Forms & Validation** - Inline validation, error messages, autofill
- **Animation** - GPU acceleration, reduced motion, timing

## Structure

```
ui-ux-frontend-design/
├── SKILL.md           # Quick reference entry point
├── AGENTS.md          # Full compiled guide
├── metadata.json      # Version and references
├── README.md          # This file
└── rules/
    ├── _sections.md   # Category definitions
    ├── access-*.md    # Accessibility rules (7)
    ├── cwv-*.md       # Core Web Vitals rules (6)
    ├── layout-*.md    # Layout rules (6)
    ├── resp-*.md      # Responsive design rules (5)
    ├── typo-*.md      # Typography rules (5)
    ├── color-*.md     # Color rules (4)
    ├── form-*.md      # Form rules (5)
    └── anim-*.md      # Animation rules (4)
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
| Accessibility & WCAG Compliance | `access-` | CRITICAL |
| Core Web Vitals Optimization | `cwv-` | CRITICAL |
| Visual Hierarchy & Layout | `layout-` | HIGH |
| Responsive & Mobile-First Design | `resp-` | HIGH |
| Typography & Font Loading | `typo-` | MEDIUM-HIGH |
| Color & Contrast | `color-` | MEDIUM |
| Forms & Validation UX | `form-` | MEDIUM |
| Animation & Performance | `anim-` | LOW-MEDIUM |

## Rule File Structure

```markdown
---
title: Rule Title Here
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: Quantified impact (e.g., "reduces bounce rate by 20%")
tags: prefix, technique, related-concepts
---

## Rule Title Here

Brief explanation of WHY this matters (1-3 sentences).

**Incorrect (description of problem):**

\`\`\`html
<!-- Code with accessibility/performance issue -->
\`\`\`

**Correct (description of solution):**

\`\`\`html
<!-- Optimized/accessible code -->
\`\`\`

Reference: [Link](url)
```

## File Naming Convention

Rules follow the pattern: `{prefix}-{description}.md`

- `prefix`: Category identifier (3-8 chars) from _sections.md
- `description`: Kebab-case description of the rule

Examples:
- `access-semantic-html.md`
- `cwv-optimize-lcp.md`
- `resp-mobile-first.md`

## Impact Levels

| Level | Description | Typical Improvement |
|-------|-------------|---------------------|
| CRITICAL | Must fix immediately | Blocks 15%+ users or 25%+ SEO impact |
| HIGH | Fix in current sprint | 20-50% improvement in UX metrics |
| MEDIUM-HIGH | Fix soon | 15-25% improvement |
| MEDIUM | Fix when convenient | 10-20% improvement |
| LOW-MEDIUM | Nice to have | 5-15% improvement |
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
4. Reference authoritative sources (W3C, MDN, Google)
5. Run validation before submitting

## Acknowledgments

- [WCAG 2.2 Guidelines](https://www.w3.org/WAI/WCAG22/quickref/)
- [web.dev Core Web Vitals](https://web.dev/articles/vitals)
- [Nielsen Norman Group](https://www.nngroup.com/)
- [MDN Web Docs](https://developer.mozilla.org/)
- [Baymard Institute](https://baymard.com/)
- [Material Design](https://m3.material.io/)
