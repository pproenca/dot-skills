# Apple iOS Human Interface Guidelines

Comprehensive design guide based on Apple's Human Interface Guidelines for iOS applications, designed for AI agents and LLMs. Contains 45 rules across 8 categories covering design foundations, layout, navigation, components, interaction, feedback, accessibility, and UX patterns.

## Overview

This skill provides best practices for building native iOS apps, covering:

- **Design Foundations**: Colors, typography, dark mode, SF Symbols, app icons
- **Layout & Spacing**: Safe areas, 8pt grid, adaptive layouts, margins
- **Navigation Patterns**: Tab bars, navigation bars, hierarchy, search
- **UI Components**: Buttons, text fields, lists, sheets, alerts, menus
- **Interaction Design**: Touch targets, gestures, haptics, keyboard
- **User Feedback**: Loading states, errors, notifications, empty states
- **Accessibility**: VoiceOver, Dynamic Type, reduce motion, focus
- **UX Patterns**: Onboarding, permissions, modality, settings

## Structure

```
apple-ios-hig/
├── SKILL.md              # Quick reference entry point
├── AGENTS.md             # Complete compiled guide
├── README.md             # This file
├── metadata.json         # Version and references
├── references/
│   ├── _sections.md      # Category definitions
│   ├── found-*.md        # Design foundation rules
│   ├── layout-*.md       # Layout rules
│   ├── nav-*.md          # Navigation rules
│   ├── comp-*.md         # Component rules
│   ├── inter-*.md        # Interaction rules
│   ├── feed-*.md         # Feedback rules
│   ├── a11y-*.md         # Accessibility rules
│   └── ux-*.md           # UX pattern rules
└── assets/
    └── templates/
        └── _template.md  # Rule template
```

## Getting Started

1. **Install the skill** in your Claude Code or AI agent environment
2. **Reference SKILL.md** for quick lookups by category
3. **Read AGENTS.md** for comprehensive guidance
4. **Copy templates** from `assets/templates/` as starting points

### Commands

```bash
# Validate skill structure
pnpm validate

# Build AGENTS.md from references
pnpm build

# Install dependencies (for validation)
pnpm install
```

## Creating a New Rule

1. Choose the appropriate category prefix from the table below
2. Create a file in `references/` with the format `{prefix}-{description}.md`
3. Follow the template in `assets/templates/_template.md`
4. Run `pnpm build` to regenerate AGENTS.md

### Prefix Reference

| Category | Prefix | Impact |
|----------|--------|--------|
| Design Foundations | `found-` | CRITICAL |
| Layout & Spacing | `layout-` | CRITICAL |
| Navigation Patterns | `nav-` | HIGH |
| UI Components | `comp-` | HIGH |
| Interaction Design | `inter-` | HIGH |
| User Feedback | `feed-` | MEDIUM-HIGH |
| Accessibility | `a11y-` | HIGH |
| UX Patterns | `ux-` | MEDIUM |

## Rule File Structure

Each rule file should contain:

```markdown
---
title: Rule Title
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW
impactDescription: Brief impact description
tags: prefix, keyword1, keyword2
---

## Rule Title

Brief explanation of WHY this matters.

**Incorrect (what's wrong):**
\`\`\`swift
// Bad example
\`\`\`

**Correct (what's right):**
\`\`\`swift
// Good example
\`\`\`

Reference: [HIG Section](https://developer.apple.com/design/human-interface-guidelines/...)
```

## File Naming Convention

- Use the category prefix followed by a descriptive kebab-case name
- Examples: `nav-tab-bar-navigation.md`, `a11y-dynamic-type.md`
- The first tag in YAML frontmatter must match the prefix

## Impact Levels

| Level | Description |
|-------|-------------|
| CRITICAL | Foundation patterns that affect entire app |
| HIGH | Important patterns for common features |
| MEDIUM-HIGH | Patterns that improve UX significantly |
| MEDIUM | Good practices with moderate impact |
| LOW | Nice-to-have optimizations |

## Scripts

| Script | Description |
|--------|-------------|
| `pnpm validate` | Validates skill structure and rules |
| `pnpm build` | Regenerates AGENTS.md from references |

## Contributing

1. Follow the existing rule format
2. Include Incorrect and Correct code examples
3. Reference official Apple HIG documentation
4. Use production-realistic code, not strawman examples
5. Quantify impact where possible

## Acknowledgments

- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/) - Official Apple design guidelines
- [Apple Developer Documentation](https://developer.apple.com/documentation/) - SwiftUI and UIKit references
- [SF Symbols](https://developer.apple.com/sf-symbols/) - Apple's icon library
