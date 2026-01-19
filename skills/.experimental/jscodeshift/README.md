# jscodeshift Best Practices Skill

A comprehensive best practices guide for jscodeshift codemod development, containing 40+ rules across 8 categories.

## Overview

This skill provides performance optimization and correctness guidelines for writing jscodeshift codemods. Rules are prioritized by impact from critical (parser configuration, AST traversal) to incremental (advanced patterns).

## Structure

```
jscodeshift/
├── SKILL.md              # Entry point with quick reference
├── AGENTS.md             # Compiled comprehensive guide
├── metadata.json         # Version and reference information
├── README.md             # This file
├── references/
│   ├── _sections.md      # Category definitions
│   ├── parser-*.md       # Parser configuration rules
│   ├── traverse-*.md     # AST traversal rules
│   ├── filter-*.md       # Node filtering rules
│   ├── transform-*.md    # AST transformation rules
│   ├── codegen-*.md      # Code generation rules
│   ├── test-*.md         # Testing strategy rules
│   ├── runner-*.md       # Runner optimization rules
│   └── advanced-*.md     # Advanced pattern rules
└── assets/
    └── templates/
        └── _template.md  # Rule template
```

## Getting Started

### Installation

```bash
pnpm install
```

### Building AGENTS.md

```bash
pnpm build
```

### Validating the Skill

```bash
pnpm validate
```

## Creating a New Rule

1. Choose the appropriate category based on impact and lifecycle stage
2. Copy the template from `assets/templates/_template.md`
3. Name the file using the pattern: `{prefix}-{description}.md`
4. Fill in the frontmatter (title, impact, impactDescription, tags)
5. Write the rule content with incorrect/correct examples
6. Rebuild AGENTS.md with `pnpm build`
7. Validate with `pnpm validate`

### Prefix Reference

| Prefix | Category | Impact |
|--------|----------|--------|
| `parser-` | Parser Configuration | CRITICAL |
| `traverse-` | AST Traversal Patterns | CRITICAL |
| `filter-` | Node Filtering | HIGH |
| `transform-` | AST Transformation | HIGH |
| `codegen-` | Code Generation | MEDIUM |
| `test-` | Testing Strategies | MEDIUM |
| `runner-` | Runner Optimization | LOW-MEDIUM |
| `advanced-` | Advanced Patterns | LOW |

## Rule File Structure

```markdown
---
title: Rule Title
impact: CRITICAL|HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: Quantified impact (e.g., "2-10× improvement")
tags: prefix, technique, tool
---

## Rule Title

Brief explanation of WHY this matters (1-3 sentences).

**Incorrect (problem description):**

\`\`\`javascript
// Code showing the anti-pattern
\`\`\`

**Correct (benefit description):**

\`\`\`javascript
// Code showing the correct approach
\`\`\`

Reference: [Source](url)
```

## File Naming Convention

Rule files follow the pattern: `{prefix}-{kebab-case-description}.md`

- First part is the category prefix (e.g., `parser-`, `traverse-`)
- Second part describes the rule in kebab-case
- Examples: `parser-typescript-config.md`, `traverse-two-pass-pattern.md`

## Impact Levels

| Level | Description | Example |
|-------|-------------|---------|
| CRITICAL | Affects all transformations, cascading failures | Wrong parser breaks all transforms |
| HIGH | Significant correctness or performance impact | Missing scope checks corrupt code |
| MEDIUM | Moderate impact on quality or efficiency | Style preservation, testing coverage |
| LOW-MEDIUM | Optimization for specific scenarios | Runner parallelization tuning |
| LOW | Advanced patterns for edge cases | Multi-file state coordination |

## Scripts

| Script | Description |
|--------|-------------|
| `pnpm build` | Compiles references into AGENTS.md |
| `pnpm validate` | Validates skill structure and content |

## Contributing

1. Follow the rule template structure exactly
2. Include both incorrect and correct code examples
3. Quantify impact where possible (e.g., "2-10× improvement")
4. Reference authoritative sources
5. Ensure first tag matches category prefix
6. Run validation before submitting

## Acknowledgments

- [facebook/jscodeshift](https://github.com/facebook/jscodeshift) - Official jscodeshift repository
- [jscodeshift.com](https://jscodeshift.com/) - Official documentation
- [Martin Fowler - Refactoring with Codemods](https://martinfowler.com/articles/codemods-api-refactoring.html)
- [recast](https://github.com/benjamn/recast) - AST-to-AST transformation
- [ast-types](https://github.com/benjamn/ast-types) - AST node definitions
