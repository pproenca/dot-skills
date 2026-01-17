# Developer Experience TUI Best Practices

Comprehensive developer experience guide for building TypeScript terminal user interfaces using Ink (React for CLIs), @clack/prompts, and @clack/core.

## Overview

This skill provides 42 performance and UX optimization rules for TUI development, organized by impact from critical to incremental.

### Structure

```
developer-experience-tui/
├── SKILL.md              # Entry point with quick reference
├── AGENTS.md             # Compiled comprehensive guide
├── metadata.json         # Version, org, references
├── README.md             # This file
└── rules/
    ├── _sections.md      # Category definitions
    ├── render-*.md       # Rendering optimization rules (6)
    ├── input-*.md        # Input handling rules (5)
    ├── comp-*.md         # Component pattern rules (6)
    ├── state-*.md        # State management rules (5)
    ├── prompt-*.md       # Prompt design rules (5)
    ├── ux-*.md           # UX feedback rules (5)
    ├── config-*.md       # Configuration rules (5)
    └── robust-*.md       # Robustness rules (5)
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

1. Determine the appropriate category based on the rule's focus
2. Create a new file with the category prefix: `{prefix}-{description}.md`
3. Include YAML frontmatter with required fields
4. Follow the template structure with incorrect/correct examples

### Category Prefixes

| Prefix | Category | Impact |
|--------|----------|--------|
| `render-` | Rendering & Output | CRITICAL |
| `input-` | Input & Keyboard | CRITICAL |
| `comp-` | Component Patterns | HIGH |
| `state-` | State & Lifecycle | HIGH |
| `prompt-` | Prompt Design | MEDIUM-HIGH |
| `ux-` | UX & Feedback | MEDIUM |
| `config-` | Configuration & CLI | MEDIUM |
| `robust-` | Robustness & Compatibility | LOW-MEDIUM |

## Rule File Structure

```markdown
---
title: Rule Title Here
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: Brief quantified impact (e.g., "eliminates flicker")
tags: prefix, keyword1, keyword2
---

## Rule Title Here

Brief explanation of WHY this matters (1-3 sentences).

**Incorrect (problem description):**

\`\`\`typescript
// Bad example with comments explaining the cost
\`\`\`

**Correct (solution description):**

\`\`\`typescript
// Good example with minimal diff from incorrect
\`\`\`

Reference: [Source](https://example.com)
```

## File Naming Convention

Rules follow the pattern: `{prefix}-{description}.md`

- `prefix`: Category identifier (3-7 lowercase chars)
- `description`: Kebab-case description of the rule

Examples:
- `render-single-write.md`
- `input-useinput-hook.md`
- `prompt-group-flow.md`

## Impact Levels

| Level | Description |
|-------|-------------|
| CRITICAL | Must fix - causes major performance or UX issues |
| HIGH | Should fix - significant improvement opportunity |
| MEDIUM-HIGH | Recommended - noticeable improvement |
| MEDIUM | Good practice - incremental improvement |
| LOW-MEDIUM | Nice to have - polish and edge cases |
| LOW | Optional - advanced optimization |

## Scripts

- `pnpm validate` - Validate skill structure and content
- `pnpm build` - Build AGENTS.md from rules

## Contributing

1. Read existing rules to understand the style and depth expected
2. Each rule should have a clear incorrect/correct example pair
3. Quantify impact where possible (N× improvement, Nms reduction)
4. Include references to authoritative sources
5. Run validation before submitting

## Key Libraries Covered

- **[Ink](https://github.com/vadimdemedes/ink)** - React for interactive command-line apps
- **[@inkjs/ui](https://github.com/vadimdemedes/ink-ui)** - UI components for Ink
- **[@clack/prompts](https://github.com/bombshell-dev/clack)** - Beautiful prompt components
- **[@clack/core](https://github.com/bombshell-dev/clack)** - Unstyled prompt primitives

## Acknowledgments

- [Command Line Interface Guidelines](https://clig.dev/) - Comprehensive CLI design principles
- [Textualize Blog](https://textual.textualize.io/blog/) - High-performance TUI algorithms
- [Kitty Keyboard Protocol](https://sw.kovidgoyal.net/kitty/keyboard-protocol/) - Modern keyboard handling
