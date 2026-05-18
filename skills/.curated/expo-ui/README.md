# @expo/ui SwiftUI Best Practices Skill

iOS SwiftUI usage guidelines for `@expo/ui/swift-ui` — covering Host boundaries, modifier composition, iOS 26 HIG composition rules, and ObservableState patterns.

## Overview

This skill provides 53 rules across 8 categories, designed to help AI agents and developers build native iOS UIs in Expo apps using SwiftUI through `@expo/ui/swift-ui`.

### Directory Structure

```
expo-ui/
├── SKILL.md           # Entry point with quick reference
├── AGENTS.md          # Compiled comprehensive guide (auto-built)
├── metadata.json      # Version, org, references
├── gotchas.md         # Failure points discovered during use
├── README.md          # This file
├── references/
│   ├── _sections.md             # Category definitions
│   ├── host-*.md                # Setup & Host boundaries (5)
│   ├── hig-*.md                 # iOS 26 HIG composition rules (7)
│   ├── mod-*.md                 # Modifiers system (8)
│   ├── layout-*.md              # Layout components (6)
│   ├── input-*.md               # Input & controls (8)
│   ├── nav-*.md                 # Navigation & overlays (8)
│   ├── display-*.md             # Display & feedback (6)
│   └── state-*.md               # State & cross-cutting (5)
└── assets/
    └── templates/
        └── _template.md         # Rule template
```

## Getting Started

### Installation

```bash
pnpm install
```

### Build AGENTS.md

```bash
pnpm build
```

### Validate Skill

```bash
pnpm validate
```

## Creating a New Rule

1. Choose the appropriate category prefix:

| Category | Prefix | Impact |
|----------|--------|--------|
| Setup & Host Boundaries | `host-` | CRITICAL |
| iOS 26 HIG Composition Rules | `hig-` | CRITICAL |
| Modifiers System | `mod-` | CRITICAL |
| Layout Components | `layout-` | HIGH |
| Input & Controls | `input-` | HIGH |
| Navigation & Overlays | `nav-` | HIGH |
| Display & Feedback | `display-` | MEDIUM-HIGH |
| State & Cross-Cutting Patterns | `state-` | MEDIUM |

2. Create a new file: `references/{prefix}-{description}.md`

3. Copy the template from `assets/templates/_template.md`

## Rule File Structure

```markdown
---
title: Rule Title Here
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: Quantified outcome (e.g., "prevents X", "enables Y")
tags: prefix, technique, tool
---

## Rule Title Here

Brief explanation of WHY this matters in the SwiftUI bridge (1-3 sentences).

**Incorrect (description of problem):**

\`\`\`tsx
// Bad code anchored to a realistic domain
\`\`\`

**Correct (description of solution):**

\`\`\`tsx
// Good code — minimal diff from incorrect
\`\`\`

Reference: [Authoritative source](https://developer.apple.com/...)
```

## File Naming Convention

Rules follow the pattern: `{prefix}-{slug}.md`

- **prefix**: Category identifier (3-7 chars) from `_sections.md`
- **slug**: Kebab-case description of the rule

Examples:
- `host-wrap-all-swiftui-roots.md`
- `hig-glass-effect-container.md`
- `mod-prop-not-style.md`

## Impact Levels

| Level | Description |
|-------|-------------|
| CRITICAL | Cascade effect — breaks every downstream component (Host, modifiers, HIG composition) |
| HIGH | Major impact on category — layout containers, primary inputs, presentation surfaces |
| MEDIUM-HIGH | Notable impact in common patterns — secondary inputs, display components |
| MEDIUM | Measurable improvement — state patterns, platform guards |
| LOW-MEDIUM | Minor optimisation for edge cases |
| LOW | Best practice with minimal practical impact |

## Scripts

| Command | Description |
|---------|-------------|
| `pnpm build` | Compile rules into AGENTS.md |
| `pnpm validate` | Check skill against quality guidelines |

## Contributing

1. Read existing rules in the same category for style consistency
2. Anchor "Incorrect" examples to realistic Expo app domains — not foo/bar
3. Keep the "Correct" diff minimal — same variable names, same structure
4. Cite an authoritative source: developer.apple.com or `expo/expo` source code
5. Quantify impact ("prevents X", "enables Y", "reduces Z×") rather than vague phrasing
6. Run validation before committing

## Acknowledgments

Built from the `@expo/ui` source (v56.0.8) and Apple's iOS 26 Human Interface Guidelines.
