# SwiftUI Best Practices Skill

A comprehensive guide for building Apple-quality iOS app UIs with SwiftUI, designed for AI agents and LLMs to achieve principal-level native app development matching Apple's Weather, Calendar, Photos, and Notes apps.

## Overview / Structure

```
swift-ui/
├── SKILL.md              # Entry point with quick reference
├── AGENTS.md             # Compiled comprehensive guide
├── metadata.json         # Version and reference information
├── README.md             # This file
├── references/
│   ├── _sections.md      # Category definitions
│   └── {prefix}-*.md     # Individual rules (51 total)
└── assets/
    └── templates/
        └── _template.md  # Rule template for extensions
```

## Getting Started

### Installation

This skill is designed for use with Claude Code and other AI agents. To use:

1. Clone or copy to your skills directory
2. Reference in your AI agent configuration

### Building

```bash
# Install dependencies (if using validation scripts)
pnpm install

# Build AGENTS.md from individual rules
pnpm build

# Validate skill structure
pnpm validate
```

### Validation

```bash
# Run validation
pnpm validate

# Or directly
node scripts/validate-skill.js ./skills/.experimental/swift-ui
```

## Creating a New Rule

1. Choose the appropriate category prefix from the table below
2. Create a new file: `references/{prefix}-{descriptive-name}.md`
3. Follow the template structure in `assets/templates/_template.md`
4. Run `pnpm build` to regenerate AGENTS.md

### Category Prefixes

| Prefix | Category | Impact |
|--------|----------|--------|
| `state-` | Data Flow & State Management | CRITICAL |
| `design-` | Visual Design System | CRITICAL |
| `comp-` | Component Selection | HIGH |
| `nav-` | Navigation Patterns | HIGH |
| `view-` | View Composition | HIGH |
| `anim-` | Animation & Haptics | MEDIUM-HIGH |
| `acc-` | Accessibility | MEDIUM-HIGH |
| `perf-` | Lists & Scroll Performance | MEDIUM |
| `platform-` | Platform Integration | MEDIUM |

## Rule File Structure

```markdown
---
title: Rule Title Here
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW
impactDescription: Quantified impact (e.g., "2-10× improvement")
tags: prefix, keyword1, keyword2
---

## Rule Title Here

Brief explanation of WHY this matters (1-3 sentences).

**Incorrect (description of the problem):**

```swift
// Bad code example
```

**Correct (description of the solution):**

```swift
// Good code example
```

Reference: [Link](https://example.com)
```

## File Naming Convention

Rule files follow the pattern: `{prefix}-{descriptive-name}.md`

- Prefix: Category identifier (e.g., `state-`, `design-`, `nav-`)
- Name: Kebab-case description of the rule
- Examples:
  - `state-observable-macro.md`
  - `design-spacing-hig-values.md`
  - `nav-navigationstack-modern.md`

## Impact Levels

| Level | Description | Examples |
|-------|-------------|----------|
| CRITICAL | Foundational patterns, wrong choice causes cascading issues | State management, HIG compliance |
| HIGH | Important patterns that significantly affect quality | Navigation, view composition |
| MEDIUM-HIGH | Polish and accessibility requirements | Animations, accessibility |
| MEDIUM | Optimization and integration patterns | Performance, platform features |
| LOW | Advanced patterns for specific cases | Edge cases, micro-optimizations |

## Scripts

| Script | Description |
|--------|-------------|
| `pnpm build` | Compiles references into AGENTS.md |
| `pnpm validate` | Validates skill structure and content |

## Contributing

1. Create rules following the template structure
2. Ensure code examples are production-realistic
3. Include both incorrect and correct examples
4. Quantify impact where possible
5. Run validation before submitting

## Acknowledgments

- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [WWDC Sessions](https://developer.apple.com/videos/)
- [Airbnb Engineering Blog](https://medium.com/airbnb-engineering)
- [Fatbobman's SwiftUI Blog](https://fatbobman.com/en/)
