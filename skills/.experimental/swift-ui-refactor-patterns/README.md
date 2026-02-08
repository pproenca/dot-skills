# SwiftUI Refactoring Patterns

Comprehensive refactoring guide for SwiftUI applications. Contains 42 rules across 8 categories, prioritized by impact to guide modernization of existing SwiftUI codebases.

## Overview/Structure

```
swift-ui-refactor-patterns/
├── SKILL.md              # Entry point with quick reference
├── AGENTS.md             # Complete compiled guide with all rules
├── README.md             # This file
├── metadata.json         # Version, org, references
├── references/
│   ├── _sections.md      # Category definitions
│   ├── api-*.md          # API Modernization rules (7)
│   ├── state-*.md        # State Architecture rules (6)
│   ├── view-*.md         # View Decomposition rules (7)
│   ├── nav-*.md          # Navigation Refactoring rules (5)
│   ├── conc-*.md         # Concurrency Migration rules (5)
│   ├── arch-*.md         # Architecture Patterns rules (5)
│   ├── type-*.md         # Type Safety rules (4)
│   └── perf-*.md         # Performance Optimization rules (3)
└── assets/
    └── templates/
        └── _template.md  # Rule template for extensions
```

## Getting Started

```bash
pnpm install
pnpm build
pnpm validate
```

## Creating a New Rule

1. Copy `assets/templates/_template.md` to `references/{prefix}-{slug}.md`
2. Fill in the frontmatter (title, impact, impactDescription, tags)
3. Write the rule explanation, incorrect example, and correct example
4. Add the rule to SKILL.md quick reference section
5. Run validation

### Prefix Reference

| Prefix | Category | Impact |
|--------|----------|--------|
| `api-` | API Modernization | CRITICAL |
| `state-` | State Architecture | CRITICAL |
| `view-` | View Decomposition | HIGH |
| `nav-` | Navigation Refactoring | HIGH |
| `conc-` | Concurrency Migration | MEDIUM-HIGH |
| `arch-` | Architecture Patterns | MEDIUM |
| `type-` | Type Safety & Protocols | LOW-MEDIUM |
| `perf-` | Performance Optimization | LOW |

## Rule File Structure

Each rule file follows this template:

```markdown
---
title: Rule Title
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: Quantified impact
tags: prefix, tag2, tag3
---

## Rule Title

Brief explanation of WHY this matters.

**Incorrect (what's wrong):**
\```swift
// Legacy code
\```

**Correct (what's right):**
\```swift
// Refactored code
\```

Reference: [Title](URL)
```

## File Naming Convention

Files follow the `{prefix}-{description}.md` pattern where:
- `{prefix}` is the category prefix from `_sections.md` (3-8 chars)
- `{description}` is a kebab-case slug describing the rule

Examples: `api-observable-macro.md`, `state-scope-minimization.md`, `view-extract-subviews.md`

## Impact Levels

| Level | Description |
|-------|-------------|
| CRITICAL | Blocks downstream improvements. Fix first. |
| HIGH | Major structural improvements with broad impact. |
| MEDIUM-HIGH | Significant improvements for specific subsystems. |
| MEDIUM | Meaningful improvements that reduce complexity. |
| LOW-MEDIUM | Safety improvements that prevent runtime issues. |
| LOW | Final polish optimizations after structural work. |

## Scripts

- `pnpm validate` - Run validation against quality checklist
- `pnpm build` - Compile AGENTS.md from individual rules

## Contributing

1. Follow the rule template exactly
2. Ensure the H2 title matches the frontmatter title
3. First tag must be the category prefix
4. Include both Incorrect and Correct code examples
5. Quantify impact where possible
6. Use realistic variable names (no foo/bar)

## Acknowledgments

- [Apple SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [WWDC Sessions on SwiftUI](https://developer.apple.com/videos/swiftui)
- [Airbnb Engineering Blog](https://medium.com/airbnb-engineering)
- [Swift by Sundell](https://www.swiftbysundell.com)
- [SwiftLee](https://www.avanderlee.com)
