# VHS Best Practices Skill

A comprehensive best practices guide for creating terminal recordings with [VHS](https://github.com/charmbracelet/vhs) by Charmbracelet.

## Overview

VHS is a CLI tool for recording terminal sessions as GIFs, MP4s, or WebM videos using declarative tape files. This skill provides 47 rules across 8 categories to help you create polished, optimized, and portable terminal demos.

## Getting Started

```bash
# Install VHS (macOS)
brew install vhs

# Install VHS (Go)
go install github.com/charmbracelet/vhs@latest

# Validate skill structure
pnpm install
pnpm build
pnpm validate
```

## Categories

| Priority | Category | Rules | Focus |
|----------|----------|-------|-------|
| 1 | Configuration | 6 | Settings order, shell, dimensions |
| 2 | Dependencies | 4 | Require validation, system deps |
| 3 | Commands | 8 | Type syntax, keys, Hide/Show |
| 4 | Timing | 8 | Sleep, Wait, pacing |
| 5 | Output | 6 | Format, framerate, optimization |
| 6 | Visual | 6 | Fonts, themes, decorations |
| 7 | CI | 5 | GitHub Actions, automation |
| 8 | Advanced | 4 | Source, clipboard, server |

## Creating a New Rule

1. Choose the appropriate category based on the rule's focus
2. Create a new file in `references/` with the category prefix
3. Follow the template in `assets/templates/_template.md`
4. Run validation to check formatting

## Rule File Structure

Each rule file follows this structure:

```markdown
---
title: Rule Title
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: quantified impact
tags: category-prefix, related-tags
---

## Rule Title

Explanation of why this matters.

**Incorrect (what's wrong):**
\`\`\`tape
bad example
\`\`\`

**Correct (what's right):**
\`\`\`tape
good example
\`\`\`
```

## File Naming Convention

Rule files follow the pattern: `{category-prefix}-{descriptive-slug}.md`

Examples:
- `config-settings-order.md`
- `timing-sleep-after-enter.md`
- `output-format-selection.md`

## Impact Levels

| Level | Description |
|-------|-------------|
| CRITICAL | Causes failures or silent bugs if ignored |
| HIGH | Significant quality or reliability impact |
| MEDIUM-HIGH | Notable improvement in output quality |
| MEDIUM | Recommended for polish and maintainability |
| LOW-MEDIUM | Minor improvements, nice to have |
| LOW | Advanced patterns for specific use cases |

## Scripts

```bash
# Build AGENTS.md from references
node scripts/build-agents-md.js .

# Validate skill structure and rules
node scripts/validate-skill.js .
```

## Contributing

1. Read existing rules to understand the style
2. Create a new rule following the template
3. Run validation before submitting
4. Ensure examples are realistic and minimal

## References

- [VHS GitHub Repository](https://github.com/charmbracelet/vhs)
- [VHS GitHub Action](https://github.com/charmbracelet/vhs-action)
- [VHS Examples](https://github.com/charmbracelet/vhs/tree/main/examples)

## Version

- **Skill Version**: 0.1.0
- **Last Updated**: January 2026
