# Google JavaScript Best Practices

A comprehensive JavaScript style and best practices skill based on Google's official JavaScript Style Guide, designed for AI agents and LLMs.

## Overview

This skill contains 47 rules across 8 categories, covering:

- Module system and import/export patterns
- Modern JavaScript language features (ES6+)
- Type safety with JSDoc annotations
- Naming conventions
- Control flow and error handling
- Function and parameter patterns
- Object and array best practices
- Formatting and code style

## Structure

```
js-google/
├── SKILL.md              # Entry point with quick reference
├── AGENTS.md             # Compiled comprehensive guide
├── metadata.json         # Version, org, references
├── README.md             # This file
├── references/
│   ├── _sections.md      # Category definitions
│   ├── module-*.md       # Module system rules (6)
│   ├── lang-*.md         # Language feature rules (8)
│   ├── type-*.md         # Type safety rules (6)
│   ├── naming-*.md       # Naming convention rules (6)
│   ├── control-*.md      # Control flow rules (5)
│   ├── func-*.md         # Function rules (5)
│   ├── data-*.md         # Data structure rules (6)
│   └── format-*.md       # Formatting rules (5)
└── assets/
    └── templates/
        └── _template.md  # Rule template for extensions
```

## Getting Started

### Installation

```bash
pnpm install
```

### Build

```bash
pnpm build
```

### Validate

```bash
pnpm validate
```

## Creating a New Rule

1. Determine the appropriate category based on the rule's purpose
2. Create a new file in `references/` with the correct prefix
3. Use the template from `assets/templates/_template.md`
4. Run validation to check formatting

### Category Prefixes

| Prefix | Category | Impact |
|--------|----------|--------|
| `module-` | Module System & Imports | CRITICAL |
| `lang-` | Language Features | CRITICAL |
| `type-` | Type Safety & JSDoc | HIGH |
| `naming-` | Naming Conventions | HIGH |
| `control-` | Control Flow & Error Handling | MEDIUM-HIGH |
| `func-` | Functions & Parameters | MEDIUM |
| `data-` | Objects & Arrays | MEDIUM |
| `format-` | Formatting & Style | LOW |

## Rule File Structure

Each rule file must include:

```markdown
---
title: Rule Title
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: Quantified impact (e.g., "prevents X bugs")
tags: category-prefix, technique, related-concepts
---

## Rule Title

Brief explanation of WHY this matters (1-3 sentences).

**Incorrect (what's wrong):**

\`\`\`javascript
// Bad code example with comments explaining the cost
\`\`\`

**Correct (what's right):**

\`\`\`javascript
// Good code example with minimal diff from incorrect
\`\`\`

Reference: [Source](URL)
```

## File Naming Convention

Rule files follow the pattern: `{prefix}-{description}.md`

- `{prefix}` - Category prefix (e.g., `module`, `lang`, `type`)
- `{description}` - Kebab-case description of the rule

Examples:
- `module-avoid-circular-dependencies.md`
- `lang-const-over-let-over-var.md`
- `type-explicit-nullability.md`

## Impact Levels

| Level | Description |
|-------|-------------|
| CRITICAL | Prevents application failures, security issues, or major bugs |
| HIGH | Prevents subtle bugs, enables tooling, improves maintainability |
| MEDIUM-HIGH | Prevents common errors, improves debugging |
| MEDIUM | Improves code clarity and consistency |
| LOW-MEDIUM | Minor improvements to code quality |
| LOW | Style consistency with minimal runtime impact |

## Scripts

- `pnpm build` - Compile AGENTS.md from rule files
- `pnpm validate` - Validate skill structure and content
- `pnpm lint` - Check rule files for formatting issues

## Contributing

1. Check existing rules to avoid duplication
2. Follow the rule template exactly
3. Include real-world incorrect/correct examples
4. Quantify impact where possible
5. Run validation before submitting

## Acknowledgments

Based on the [Google JavaScript Style Guide](https://google.github.io/styleguide/jsguide.html).
