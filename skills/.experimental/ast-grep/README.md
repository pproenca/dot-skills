# ast-grep Best Practices Skill

Comprehensive best practices guide for ast-grep rule writing and usage, designed for AI agents and LLMs.

## Overview

This skill contains 42 rules across 8 categories, covering pattern syntax, meta variables, rule composition, constraints, rewrites, project organization, performance, and testing.

## Structure

```
ast-grep/
├── SKILL.md              # Entry point with quick reference
├── AGENTS.md             # Compiled comprehensive guide
├── metadata.json         # Version, org, references
├── README.md             # This file
├── references/
│   ├── _sections.md      # Category definitions
│   ├── pattern-*.md      # Pattern correctness rules (7)
│   ├── meta-*.md         # Meta variable rules (6)
│   ├── compose-*.md      # Rule composition rules (6)
│   ├── const-*.md        # Constraint design rules (5)
│   ├── rewrite-*.md      # Rewrite correctness rules (5)
│   ├── org-*.md          # Project organization rules (5)
│   ├── perf-*.md         # Performance optimization rules (4)
│   └── test-*.md         # Testing & debugging rules (4)
└── assets/
    └── templates/
        └── _template.md  # Rule template for extensions
```

## Getting Started

```bash
# Install dependencies (from skill directory)
pnpm install

# Build AGENTS.md from references
pnpm build

# Validate skill structure and content
pnpm validate
```

## Creating a New Rule

1. Choose the appropriate category based on the rule's focus:

| Category | Prefix | Use For |
|----------|--------|---------|
| Pattern Correctness | `pattern-` | Pattern syntax issues |
| Meta Variable Usage | `meta-` | Meta variable problems |
| Rule Composition | `compose-` | Combining rules |
| Constraint Design | `const-` | Filtering matches |
| Rewrite Correctness | `rewrite-` | Code transformation |
| Project Organization | `org-` | Project structure |
| Performance Optimization | `perf-` | Speed improvements |
| Testing & Debugging | `test-` | Rule validation |

2. Create a new file: `references/{prefix}-{descriptive-name}.md`

3. Follow the template in `assets/templates/_template.md`

4. Rebuild AGENTS.md: `pnpm build`

## Rule File Structure

```markdown
---
title: Rule Title in Imperative Form
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: quantified impact
tags: category-prefix, technique, concepts
---

## Rule Title in Imperative Form

Why this matters (1-3 sentences).

**Incorrect (problem description):**

\`\`\`yaml
# Bad example
\`\`\`

**Correct (solution description):**

\`\`\`yaml
# Good example
\`\`\`

Reference: [Link](url)
```

## File Naming Convention

Files follow the pattern: `{prefix}-{description}.md`

- **prefix**: Category identifier (pattern, meta, compose, etc.)
- **description**: Kebab-case description of the rule

Examples:
- `pattern-valid-syntax.md`
- `meta-naming-convention.md`
- `compose-all-for-and-logic.md`

## Impact Levels

| Level | Description |
|-------|-------------|
| CRITICAL | Causes failures or silent bugs |
| HIGH | Leads to significant issues |
| MEDIUM-HIGH | Important for correctness |
| MEDIUM | Affects maintainability |
| LOW-MEDIUM | Nice to have improvements |
| LOW | Edge case optimizations |

## Scripts

| Script | Description |
|--------|-------------|
| `pnpm build` | Compile references into AGENTS.md |
| `pnpm validate` | Check skill structure and content |

## Contributing

1. Read existing rules for style consistency
2. Use the template for new rules
3. Include both incorrect and correct examples
4. Provide quantified impact descriptions
5. Reference official documentation
6. Run validation before submitting

## Acknowledgments

- [ast-grep](https://ast-grep.github.io/) - The fast and polyglot tool for code structural search
- [ast-grep-essentials](https://github.com/coderabbitai/ast-grep-essentials) - Community rules collection
- [Tree-sitter](https://tree-sitter.github.io/tree-sitter/) - Underlying parser technology
