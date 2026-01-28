# Browser Extension TypeScript Skill

A comprehensive style and architecture skill for building TypeScript browser extensions, extracted from the Dark Reader codebase.

## Overview

This skill teaches patterns for building robust, maintainable browser extensions that work across Chrome, Firefox, and Edge. It covers:

- **Manifest V3** service worker patterns and migration strategies
- **Code organization** for extension contexts (background, content scripts, UI)
- **Cross-context communication** with typed message passing
- **Error handling** for browser extension edge cases
- **Testing strategies** for extension code

## Getting Started

1. Install dependencies:
   ```bash
   pnpm install
   ```

2. Build the skill:
   ```bash
   pnpm build
   ```

3. Validate the skill:
   ```bash
   pnpm validate
   ```

## Creating a New Rule

1. Copy the template:
   ```bash
   cp assets/templates/_template.md references/{prefix}-{slug}.md
   ```

2. Fill in the frontmatter:
   - `title`: Rule name in imperative form
   - `impact`: CRITICAL, HIGH, MEDIUM, or LOW
   - `impactDescription`: Brief explanation of why this matters
   - `tags`: Comma-separated keywords

3. Write the rule content with Incorrect/Correct examples

4. Run validation:
   ```bash
   pnpm validate
   ```

## Rule File Structure

```markdown
---
title: Rule title
impact: HIGH
impactDescription: Why this rule matters
tags: category, feature, pattern
---

# Rule title

Brief explanation of the rule.

## Incorrect

\`\`\`typescript
// Anti-pattern example
\`\`\`

## Correct

\`\`\`typescript
// Correct pattern example
\`\`\`

## Why This Matters

- Benefit 1
- Benefit 2
```

## File Naming Convention

All rule files use kebab-case with a category prefix:

| Prefix | Category |
|--------|----------|
| `mv3-` | Manifest V3 patterns |
| `style-` | Code style and organization |
| `comp-` | Component patterns |
| `err-` | Error handling |
| `test-` | Testing patterns |

Examples:
- `mv3-service-worker.md`
- `style-directory-structure.md`
- `err-storage-operations.md`

## Impact Levels

| Level | Meaning | Examples |
|-------|---------|----------|
| CRITICAL | Breaking without this | MV3 service worker migration, alarms API |
| HIGH | Major quality/reliability impact | Error handling, type safety |
| MEDIUM | Moderate improvement | Code organization, naming |
| LOW | Minor enhancement | Stylistic preferences |

## Scripts

| Script | Description |
|--------|-------------|
| `pnpm build` | Build AGENTS.md from rule files |
| `pnpm validate` | Run validation checks |
| `pnpm validate --strict` | Fail on warnings too |

## Contributing

1. Create a new rule file following the template
2. Ensure all frontmatter fields are filled
3. Include realistic code examples
4. Run `pnpm validate` before submitting
5. Keep rules focused on one concept

## Source

Patterns extracted from [Dark Reader](https://github.com/darkreader/darkreader):
- 310 TypeScript files analyzed
- 20k+ GitHub stars
- Active development since 2014
- Supports Chrome, Firefox, Edge, Safari

## License

MIT - Patterns derived from Dark Reader (MIT licensed)
